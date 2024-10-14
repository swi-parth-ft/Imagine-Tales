const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendFriendRequestNotification = functions.firestore
    .document("Children2/{toId}/friendRequests/{fromId}")
    .onCreate(async (snap, context) => {
      const fromId = context.params.fromId;
      const fromChildDoc = await admin.firestore()
          .collection("Children2")
          .doc(fromId)
          .get();
      const fromChildName = fromChildDoc.data().name;
      const toChildId = context.params.toId;
      const toChildDoc = await admin.firestore()
          .collection("Children2")
          .doc(toChildId)
          .get();
      const recipientToken = toChildDoc.data().fcmToken;
      console.log("Recipient token:", recipientToken);
      if (recipientToken) {
        const message = {
          token: recipientToken,
          notification: {
            title: "New Friend Request",
            body: `${fromChildName} sent you a friend request!`,
          },
          data: {
            fromUserId: fromId,
          },
          apns: {
            payload: {
              aps: {
                sound: "notification",
              },
            },
          },
        };
        return admin.messaging().send(message)
            .then((response) => {
              console.log("Notification sent successfully:", response);
            })
            .catch((error) => {
              console.error("Error sending notification:", error);
            });
      } else {
        console.log("No FCM token for child:", toChildId);
        return null;
      }
    });

exports.sendLikeNotification = functions.firestore
    .document("Story/{storyId}/likes/{likeId}")
    .onCreate(async (snap, context) => {
      const likeId = context.params.likeId;
      const storyId = context.params.storyId;
      const likeDoc = await admin.firestore()
          .collection("Story")
          .doc(storyId)
          .collection("likes")
          .doc(likeId)
          .get();

      if (!likeDoc.exists) {
        console.error(`Like document with ID ${likeId} does not exist`);
        return null;
      }

      const likerChildId = likeDoc.data().childId;

      if (!likerChildId) {
        console.error(`Like document with ID ${likeId}`);
        return null;
      }
      const storyDoc = await admin.firestore()
          .collection("Story")
          .doc(storyId)
          .get();
      const storyOwnerId = storyDoc.data().childId;
      const storyOwnerDoc = await admin.firestore()
          .collection("Children2")
          .doc(storyOwnerId)
          .get();

      const recipientToken = storyOwnerDoc.data().fcmToken;

      // Fetch the name of the child who liked the story (likerChildId)
      const likerDoc = await admin.firestore()
          .collection("Children2")
          .doc(likerChildId)
          .get();

      if (!likerDoc.exists) {
        console.error(`Child with ID ${likerChildId} does not exist`);
        return null;
      }

      const likerName = likerDoc.data().name;

      if (!likerName) {
        console.error(`Child with ID ${likerChildId} does not have a name`);
        return null;
      }

      if (recipientToken) {
        const message = {
          token: recipientToken,
          notification: {
            title: "Your Story Got a Like!",
            body: `${likerName} liked your story!`,
          },
          data: {
            storyId: storyId,
          },
          apns: {
            payload: {
              aps: {
                sound: "notification",
              },
            },
          },
        };

        return admin.messaging().send(message)
            .then((response) => {
              console.log("Notification sent successfully:", response);
            })
            .catch((error) => {
              console.error("Error sending notification:", error);
            });
      } else {
        console.log("No FCM token for child:", storyOwnerId);
        return null;
      }
    });

exports.sendStoryStatusNotification = functions.firestore
    .document("Story/{id}")
    .onUpdate(async (change, context) => {
      const storyId = context.params.id;
      const beforeData = change.before.data();
      const afterData = change.after.data();
      if (beforeData.status !== afterData.status) {
        const newStatus = afterData.status;
        const childId = afterData.childId;
        const childDoc = await admin.firestore()
            .collection("Children2")
            .doc(childId)
            .get();

        if (!childDoc.exists) {
          console.error(`Child with ID ${childId} does not exist`);
          return null;
        }
        const storyTitle = afterData.title;
        const recipientToken = childDoc.data().fcmToken;
        const notificationTitle = "Your story status has an update!";
        const notificationBody = `${storyTitle} has been ${newStatus}ed.`;

        if (recipientToken) {
          const message = {
            token: recipientToken,
            notification: {
              title: notificationTitle,
              body: notificationBody,
            },
            data: {
              storyId: storyId, // Pass storyId for any further actions
            },
            apns: {
              payload: {
                aps: {
                  sound: "notification",
                },
              },
            },
          };

          return admin.messaging().send(message)
              .then((response) => {
                console.log("Notification sent successfully:", response);
              })
              .catch((error) => {
                console.error("Error sending notification:", error);
              });
        } else {
          console.log("No FCM token for child:", childId);
          return null;
        }
      }
      return null; // If status did not change
    });

exports.sendFriendAcceptanceNotification = functions.firestore
    .document("Children2/{childId}/friends/{friendUserId}")
    .onCreate(async (snap, context) => {
      const childId = context.params.childId;
      const friendUserId = context.params.friendUserId;

      const friendDoc = await admin.firestore()
          .collection("Children2")
          .doc(friendUserId)
          .get();

      if (!friendDoc.exists) {
        console.error(`Friend with ID ${friendUserId} does not exist`);
        return null;
      }

      const friendName = friendDoc.data().name;
      if (!friendName) {
        console.error(`Friend with ID ${friendUserId} does not have a name`);
        return null;
      }

      const childDoc = await admin.firestore()
          .collection("Children2")
          .doc(childId)
          .get();
      if (!childDoc.exists) {
        console.error(`Child with ID ${childId} does not exist`);
        return null;
      }

      const recipientToken = childDoc.data().fcmToken;

      if (recipientToken) {
        const message = {
          token: recipientToken,
          notification: {
            title: "Friend Request Accepted",
            body: `${friendName} accepted your friend request!`,
          },
          data: {
            friendUserId: friendUserId,
          },
          apns: {
            payload: {
              aps: {
                sound: "notification",
              },
            },
          },
        };

        return admin.messaging().send(message)
            .then((response) => {
              console.log("Notification sent successfully:", response);
            })
            .catch((error) => {
              console.error("Error sending notification:", error);
            });
      } else {
        console.log("No FCM token for child:", childId);
        return null;
      }
    });

exports.sendSharedStoryNotification = functions.firestore
    .document("Children2/{childId}/sharedStories/{sharedId}")
    .onCreate(async (snap, context) => {
      const data = snap.data();
      const fromChildId = data.fromid;
      const storyId = data.storyid;
      const toId = context.params.childId;
      const recipientDoc = await admin.firestore()
          .collection("Children2")
          .doc(toId)
          .get();
      if (!recipientDoc.exists) {
        console.error(`Child with ID ${toId} does not exist`);
        return null;
      }
      const recipientToken = recipientDoc.data().fcmToken;
      if (recipientToken) {
        const message = {
          token: recipientToken,
          notification: {
            title: "New Shared Story!",
            body: `${fromChildId} shared a story with you!`,
          },
          data: {
            storyId: storyId,
          },
          apns: {
            payload: {
              aps: {
                sound: "notification",
              },
            },
          },
        };
        return admin.messaging().send(message)
            .then((response) => {
              console.log("Notification sent successfully:", response);
            })
            .catch((error) => {
              console.error("Error sending notification:", error);
            });
      } else {
        console.log("No FCM token for child:", toId);
        return null;
      }
    });

exports.sendStoryPostedNotification = functions.firestore
    .document("Story/{storyId}")
    .onCreate(async (snap, context) => {
      const storyData = snap.data();
      const childUsername = storyData.childUsername;
      const parentId = storyData.parentId;

      console.log("New story posted by:", childUsername);
      console.log("Parent ID:", parentId);

      const parentDoc = await admin.firestore()
          .collection("users")
          .doc(parentId)
          .get();

      if (!parentDoc.exists) {
        console.error(`Parent with ID ${parentId} does not exist`);
        return null;
      }

      const parentToken = parentDoc.data().fcmToken;

      if (parentToken) {
        const message = {
          token: parentToken,
          notification: {
            title: "New Story Posted",
            body: `${childUsername} posted a new story!`,
          },
          data: {
            storyId: context.params.storyId,
          },
          apns: {
            payload: {
              aps: {
                sound: "notification",
              },
            },
          },
        };
        return admin.messaging().send(message)
            .then((response) => {
              console.log("Notification sent successfully:", response);
            })
            .catch((error) => {
              console.error("Error sending notification:", error);
            });
      } else {
        console.log("No FCM token for parent:", parentId);
        return null;
      }
    });
