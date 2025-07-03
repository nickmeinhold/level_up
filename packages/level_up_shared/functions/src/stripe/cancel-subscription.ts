import Stripe from 'stripe';
import {defineString} from 'firebase-functions/params';
import {HttpsError, onCall} from 'firebase-functions/v2/https';
import {getFirestore} from 'firebase-admin/firestore';
import {logger} from 'firebase-functions/v2';

export const cancelSubscrition = onCall(
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

      const subscription = await stripe.subscriptions
        .cancel(data['subscriptionId']);

      return {'canceled': subscription.id};
    } catch (e) {
      throw new HttpsError('aborted', `${e}.`);
    }
  });
