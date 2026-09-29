const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.onUserCreated = functions.auth.user().onCreate(async (user) => {
  const db = admin.firestore();
  await db.collection('users').doc(user.uid).set({
    email: user.email,
    name: '',
    phone: '',
    role: 'tenant',
    is_verified: false,
    profile_image: '',
    location: '',
    created_at: admin.firestore.FieldValue.serverTimestamp(),
  }, { merge: true });
});

exports.onListingSubmitted = functions.firestore.document('listings/{listingId}').onCreate(async (snap, context) => {
  const data = snap.data();
  await admin.firestore().collection('notifications').add({
    type: 'new_verification_request',
    target: 'admin',
    message: 'Listing pending verification',
    listing_id: context.params.listingId,
    created_at: admin.firestore.FieldValue.serverTimestamp(),
  });
  await admin.firestore().collection('admin_logs').add({
    admin_id: 'system',
    action: 'listing_submitted',
    target_id: context.params.listingId,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });
});

exports.onServiceSubmitted = functions.firestore.document('services/{serviceId}').onCreate(async (snap, context) => {
  await admin.firestore().collection('notifications').add({
    type: 'service_verification_request',
    target: 'admin',
    message: 'Service provider verification request',
    service_id: context.params.serviceId,
    created_at: admin.firestore.FieldValue.serverTimestamp(),
  });
});

exports.sendNotification = functions.https.onCall(async (data, context) => {
  const userId = data.userId;
  const message = data.message;
  if (!userId || !message) return { status: 'failed' };

  await admin.firestore().collection('notifications').add({
    user_id: userId,
    message,
    read: false,
    created_at: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { status: 'sent' };
});
