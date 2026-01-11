const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.setAdmin = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "You must be logged in."
    );
  }

  const callerIsAdmin = context.auth.token.admin === true;
  if (!callerIsAdmin) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Only admins can change admin status."
    );
  }

  const uid = data.uid;
  const makeAdmin = data.admin === true;

  if (!uid || typeof uid !== "string") {
    throw new functions.https.HttpsError("invalid-argument", "Missing uid.");
  }

  await admin.auth().setCustomUserClaims(uid, { admin: makeAdmin });

  return { ok: true, uid, admin: makeAdmin };
});
