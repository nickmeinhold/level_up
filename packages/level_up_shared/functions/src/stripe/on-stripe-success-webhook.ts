import {Stripe} from 'stripe';
import {onRequest} from 'firebase-functions/v2/https';
import {defineString} from 'firebase-functions/params';
import {logger} from 'firebase-functions/v2';
import {StringParam} from 'firebase-functions/lib/params/types';
import {getFirestore} from 'firebase-admin/firestore';

export const handleStripeWebhook = onRequest(async (request, response) => {
  const stripeKey: StringParam = defineString('STRIPE_PRIVATE_KEY');
  const stripe = new Stripe(stripeKey.value());
  const webhookKey: StringParam = defineString('STRIPE_WEBHOOK_KEY');

  const sig = request.get('stripe-signature');

  if (!sig) {
    throw new ReferenceError('sig was undefined or null');
  }

  try {
    const event: Stripe.Event = stripe.webhooks.constructEvent(
      request.rawBody,
      sig,
      webhookKey.value(),
    );

    const db = getFirestore();

    // Implement idempotency by checking if the event has already been
    // processed.
    const subscriptionEventsDoc = db.collection('subscription-events')
      .doc(event.id);
    const subscriptionEventsDocSnapshot = await subscriptionEventsDoc.get();

    if (!subscriptionEventsDocSnapshot) {
      throw new ReferenceError('subscriptionDocSnapshot was undefined or null');
    }

    const data = subscriptionEventsDocSnapshot.data();
    if (data && (data.id == event.id)) {
      logger.info(`Event ${event.id} already processed. Skipping.`);
      response.status(200).send('Event already processed.');
      return;
    }

    // Handle subscription-specific events
    switch (event.type) {
    case 'customer.subscription.created': {
      const subscription: Stripe.Subscription = event.data.object;

      logger.info(`Subscription created: subscriptionId: ${subscription.id}, 
      customerId: ${subscription.customer}`);

      // Assuming you pass userId as metadata when creating subscription
      const userId = subscription.metadata?.firebaseUID;
      if (!userId) {
        throw new ReferenceError(
          'userId was not present in subscription metadata');
      }

      const subscriptionDoc = db.collection('subscriptions').doc(userId);
      await subscriptionDoc.update(
        {
          subscriptionId: subscription.id,
          status: subscription.status,
        },
      );

      logger.info(`User ${userId} subscription status updated to 
      ${subscription.status}`);

      break;
    }

    case 'customer.subscription.updated': {
      const subscription: Stripe.Subscription = event.data.object;

      logger.info(`Subscription updated: subscriptionId: ${subscription.id}, 
      newStatus: ${subscription.status}`);
      const userId = subscription.metadata?.firebaseUID;

      if (!userId) {
        throw new ReferenceError(`Subscription ${subscription.id} ` +
          'updated without userId metadata.');
      }

      const subscriptionDoc = db.collection('subscriptions').doc(userId);

      await subscriptionDoc.update({'status': subscription.status});

      logger.info(`User ${userId} subscription status updated to 
        ${subscription.status}`);

      break;
    }

    case 'customer.subscription.deleted': {
      const subscription = event.data.object as Stripe.Subscription;
      logger.info('Subscription deleted:', {subscriptionId: subscription.id});
      const userId = subscription.metadata?.firebaseUID;

      if (!userId) {
        logger.warn(`Subscription ${subscription.id} ` +
          'deleted without userId metadata.');
        break;
      }

      const subscriptionDoc = db.collection('subscriptions').doc(userId);

      await subscriptionDoc.update({
        'status': subscription.status, // e.g., 'canceled'
        'subscriptionId': null, // Clear the subscription ID
      });

      logger.info(`User ${userId} subscription status updated to ` +
        `${subscription.status}`);

      break;
    }

    case 'invoice.paid': {
      const invoice: Stripe.Invoice = event.data.object;
      logger.info(`Invoice paid: invoiceId: ${invoice.id}, ` +
        `customerId: ${invoice.customer}`);

      // Grant access to services after a successful payment.
      // Ensure that the subscription data is updated accordingly.

      const querySnapshot = await db.collection('subscriptions')
        .where('stripeCustomerId', '==', invoice.customer).get();

      if (querySnapshot.docs.length === 0) {
        throw new RangeError('There was no subscription doc for the customer');
      }

      if (querySnapshot.docs.length > 1) {
        throw new RangeError('There was more than one subscription ' +
          'doc for the customer');
      }

      await querySnapshot.docs[0].ref.update({'invoiceStatus': invoice.status,
        'nextPaymentDate': invoice.next_payment_attempt});

      logger.info(`Customer ${invoice.customer} subscription doc updated ` +
        'after invoice paid.');

      break;
    }

    case 'invoice.payment_failed': {
      const invoice = event.data.object as Stripe.Invoice;

      logger.warn(`Invoice payment failed: invoiceId: ${invoice.id}, ` +
        `customerId: ${invoice.customer}`);

      // Notify user, update subscription status to 'past_due' or 'unpaid'
      const userId = invoice.metadata?.userId;

      if (!userId) {
        logger.warn(`Invoice ${invoice.id} payment failed ` +
          'without userId metadata.');
        break;
      }

      const querySnapshot = await db.collection('subscriptions')
        .where('stripeCustomerId', '==', invoice.customer).get();

      if (querySnapshot.docs.length === 0) {
        throw new RangeError('There was no subscription doc for the customer');
      }

      if (querySnapshot.docs.length > 1) {
        throw new RangeError('There was more than one subscription ' +
          'doc for the customer');
      }

      await querySnapshot.docs[0].ref.update({'invoiceStatus': invoice.status});

      logger.info(`User ${userId} invvoice status updated to 
        ${invoice.status} after payment failed.`);
      break;
    }

    case 'checkout.session.completed': {
      const session: Stripe.Checkout.Session = event.data.object;
      console.log(`Checkout session completed: ${session.id}`);
      // Note: For subscriptions, the payment isn't confirmed here yet
      break;
    }

    default:
      logger.info(`Unhandled event type: ${event.type}`);
    }
  } catch (err: unknown) {
    response.status(400).send(`Webhook Error: ${err}`);
    throw new Error(`Webhook Error: ${err}`);
  }

  // Send a 200 response to Stripe. It's crucial to respond quickly.
  response.status(200).send('Webhook received and processed.');
});
