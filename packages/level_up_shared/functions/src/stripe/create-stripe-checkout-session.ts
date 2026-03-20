import Stripe from 'stripe';
import {defineString} from 'firebase-functions/params';
import {HttpsError, onCall} from 'firebase-functions/v2/https';
import {FieldValue, getFirestore} from 'firebase-admin/firestore';
import * as admin from 'firebase-admin';
import {logger} from 'firebase-functions/v2';

export const createCheckoutSession = onCall(
  async (request) => {
    const stripeKey = defineString('STRIPE_PRIVATE_KEY');
    const stripe = new Stripe(stripeKey.value());

    const appBaseUrl = defineString('APP_BASE_URL');
    const stripePriceId = defineString('STRIPE_PRICE_ID');

    const db = getFirestore();

    try {
      if (!request.auth) {
        throw new HttpsError('unauthenticated',
          'request.auth was undefined.');
      }

      const userId = request.auth.uid;

      // 1. Create or retrieve Stripe customer.
      // Use an idempotency key based on userId to prevent duplicate customers
      // if concurrent requests arrive (e.g., user double-clicks checkout).
      const user = await admin.auth().getUser(userId);
      const customers = await stripe.customers.list({
        email: user.email,
        limit: 1,
      });

      let customerId: string | undefined = customers.data[0]?.id;
      if (customerId) {
        logger.log(`Customer with id ${customerId} has already been created.`);
      } else {
        const customer = await stripe.customers.create(
          {email: user.email, metadata: {firebaseUID: userId}},
          {idempotencyKey: `create-customer-${userId}`},
        );
        customerId = customer.id;
        logger.log(`Created customer with id ${customerId}.`);
      }

      const sessionParams: Stripe.Checkout.SessionCreateParams = {
        customer: customerId,
        mode: 'subscription', // Essential for subscription payments
        line_items: [
          {
            price: stripePriceId.value(),
            quantity: 1,
          },
        ],
        // success_url and cancel_url redirect the user after checkout
        success_url: `https://${appBaseUrl.value()}/#/success?session_id={CHECKOUT_SESSION_ID}`,
        cancel_url: `https://${appBaseUrl.value()}/#/cancel`,
        // Pass metadata to link the Stripe session/subscription
        // back to your user. This is still important as it can be accessed
        // from the Invoice/Subscription events in the webhook, even if the
        // customer ID is already linked.
        metadata: {
          firebaseUID: userId, // This userId will be available in the webhook
        },
        subscription_data: {
          metadata: {
            firebaseUID: userId,
          },
        },
      };

      // Create a new Checkout Session using the explicitly typed parameters
      const session = await stripe.checkout.sessions.create(sessionParams);

      // 3. Write to Firestore
      const subscriptionDoc = db
        .collection('subscriptions')
        .doc(request.auth.uid);
      await subscriptionDoc.set({
        stripeCustomerId: customerId,
        createdAt: FieldValue.serverTimestamp(),
      }, {merge: true});

      logger.log(`Created customer ${customerId} 
        for firebase user ${request.auth.uid}`);

      return {url: session.url};
    } catch (e) {
      throw new HttpsError('aborted', `${e}.`);
    }
  });
