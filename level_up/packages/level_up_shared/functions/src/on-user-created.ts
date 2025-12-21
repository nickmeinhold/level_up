import {AuthUserRecord, beforeUserCreated}
  from 'firebase-functions/v2/identity';
import {logger} from 'firebase-functions';
import {getFirestore} from 'firebase-admin/firestore';


/**
 * Triggered when a new user is created via Firebase Authentication
 * Creates a corresponding subscription document in Firestore.
 */
export const onUserCreated = beforeUserCreated(async (event) => {
  if (!event.data) {
    throw new ReferenceError('event.data was undefined');
  }

  const record : AuthUserRecord = event.data;

  try {
    await getFirestore()
      .collection('subscriptions')
      .doc(record.uid)
      .set({status: 'incomplete'}, {merge: false});

    logger.info(`Created subscription document for ${record.uid}`);
  } catch (error) {
    logger.error('Failed to create subscription document', error);
    throw new Error('Failed to create subscription document');
  }
});
