// Firebase Config
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
admin.initializeApp();
const db = admin.firestore();

// Sendgrid Config
import * as sgMail from "@sendgrid/mail";

const API_KEY = functions.config().sendgrid.key;
const TEMPLATE_ID = functions.config().sendgrid.template;
sgMail.setApiKey(API_KEY);

// Sends email via HTTP. Can be called from frontend code.
export const genericEmail = functions.https.onCall(async (data, context) => {
  if (!context.auth && !context.auth.token.email) {
    throw new functions.https.HttpsError(
        "failed-precondition", "Must be logged with an email address"
    );
  }

  const msg = {
    to: context.auth.token.email,
    from: "zach@zachphelps.com",
    templateId: TEMPLATE_ID,
    dynamic_template_data: {
      subject: data.subject,
      name: data.text,
    },
  };

  await sgMail.send(msg);

  // Handle errors here

  // Response must be JSON serializable
  return {success: true};
});

// Emails the author when a new comment is added to a post
export const newEvent = functions.firestore.document(
    "tenants/{tenantID}/events/{id}").onCreate( async (change, context) => {
  // Read the post document
  const tenantSnap = await db.collection("tenants")
      .doc(context.params.tenantID).get();

  // Raw Data
  const tenant = tenantSnap.data();
  const event = change.data();

  // Email
  const msg = {
    to: "zach@zachphelps.com",
    from: "zach@zachphelps.com",
    templateId: TEMPLATE_ID,
    dynamic_template_data: {
      subject: `New Event Created in ${tenant.name}`,
      name: event.title,
      //             text: `${comment.user} said... ${comment.text}`
    },
  };

  // Send it
  return sgMail.send(msg);
});

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
// export const helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
