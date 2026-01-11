const admin = require("firebase-admin");

admin.initializeApp();

async function main() {
  const uid = process.argv[2];
  if (!uid) {
    console.log("Usage: node make_first_admin.js <UID>");
    process.exit(1);
  }

  await admin.auth().setCustomUserClaims(uid, { admin: true });
  console.log(`Set admin=true for uid: ${uid}`);
  process.exit(0);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
