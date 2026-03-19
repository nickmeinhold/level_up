import Stripe from 'stripe';
import {defineString} from 'firebase-functions/params';
import {HttpsError, onCall} from 'firebase-functions/v2/https';
import {getFirestore} from 'firebase-admin/firestore';
import {logger} from 'firebase-functions/v2';

export const cancelSubscription = onCall(
  async (request) => {
    const stripeKey = defineString('STRIPE_PRIVATE_KEY');
    const stripe = new Stripe(stripeKey.value());
    const db = getFirestore();

    try {
      logger.info('Canceling subscription.');

      if (!request.auth) {
        throw new ReferenceError('request.auth was undefined.');
      }

      const userId = request.auth.uid;
      const subscriptionDoc = db.collection('subscriptions').doc(userId);
      const subscriptionDocSnapshot = await subscriptionDoc.get();

      if (!subscriptionDocSnapshot) {
        throw new ReferenceError('subscriptionDocSnapshot was ' +
          'undefined or null');
      }

      const data = subscriptionDocSnapshot.data();

      if (!data) {
        throw new ReferenceError('subscriptionDocSnapshot data was ' +
          'undefined or null');
      }

      const subscriptionId = data['subscriptionId'];
      if (!subscriptionId) {
        throw new Error('No subscriptionId found in subscription document.');
      }

      const subscription = await stripe.subscriptions.cancel(subscriptionId);

      // Only update Firestore after Stripe confirms cancellation.
      if (subscription.status === 'canceled') {
        await subscriptionDoc.update({
          status: 'cancelled',
          cancelledAt: new Date().toISOString(),
        });
      }

      return {'canceled': subscription.id, 'status': subscription.status};
    } catch (e) {
      throw new HttpsError('aborted', `${e}.`);
    }
  });
