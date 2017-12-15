const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

exports.sendFriendRequestNotification = functions.database.ref('/users/{userID}/requests/received').onWrite(event => {
  const userID = event.params.userID;

  console.log('New friend request sent to:', userID);

  // Get the list of device notification tokens.
  console.log('/users/' + userID + '/notificationToken');
  const getDeviceTokensPromise = admin.database().ref('/users/' + userID + '/notificationToken').once('value');

  return Promise.all([getDeviceTokensPromise]).then(results => {
    const tokensSnapshot = results[0];

    // Check if there are any device tokens.
    if (!tokensSnapshot.hasChildren()) {
      return console.log('There are no notification tokens to send to.');
    }
    console.log('There are', tokensSnapshot.numChildren(), 'tokens to send notifications to.');

    // Notification details.
    const payload = {
      notification: {
        title: 'You received a new friend request!',
        body: '',
        icon: '',
        click_action: 'notifications',
        badge: '1'
      }
    };

    // Listing all tokens.
    const tokens = Object.keys(tokensSnapshot.val());

    // Send notifications to all tokens.
    return admin.messaging().sendToDevice(tokens, payload).then(response => {
      // For each message, check if there was an error.
      const tokensToRemove = [];
      response.results.forEach((result, index) => {
        const error = result.error;
        if (error) {
          console.error('Failure sending notifications to', tokens[index], error);
          // Cleanup the tokens who are not registered anymore.
          if (error.code === 'messaging/invalid-registration-token' ||
              error.code === 'messaging/registration-token-not-registered') {
                tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
          }
        }
      });
      return Promise.all(tokensToRemove);
    });

  })
});

exports.sendNewCommentNotification = functions.database.ref('/mediaItems/{mediaID}/comments/{commentID}').onCreate(event => {
  const mediaID = event.params.mediaID;
  const commentID = event.params.commentID;

  const getCreatorID = admin.database().ref('/mediaItems/' + mediaID + '/creatorID').once('value');
  const getSenderID = admin.database().ref('/mediaItems/' + mediaID + '/comments/' + commentID + '/senderID').once('value');
  const getMediaType = admin.database().ref('/mediaItems/' + mediaID + '/type').once('value');

  console.log('CreatorID: ' + getCreatorID)
  const getSenderUsername = admin.database().ref('/users/' + getSenderID + '/username').once('value');

  const getDeviceTokensPromise = admin.database().ref('/users/' + getCreatorID + '/notificationToken').once('value');
  const getBadgeCount = admin.database().ref('/users/' + getCreatorID + '/badgeCount').once('value');

  return Promise.all([getDeviceTokensPromise, getBadgeCount]).then(results => {
    const tokensSnapshot = results[0];
    const badgeSnapshot = results[1];
    //const senderSnapshot = results[1];
    var count = badgeSnapshot.val() + 1;
    console.log('COUNT', count);

    admin.database().ref('/users/' + getCreatorID + '/badgeCount').set(count);
    // Check if there are any device tokens.
    if (!tokensSnapshot.hasChildren()) {
      return console.log('There are no notification tokens to send to.');
    }

    console.log('There are', tokensSnapshot.numChildren(), 'tokens to send notifications to.');
    //console.log('Fetched sender info', senderSnapshot);

    // Notification details.
    const payload = {
      notification: {
        title: '',
        body: getSenderUsername + ' commented on your ' + getMediaType + ".",
        //icon: senderSnapshot.photoURL,
        click_action: 'mediaView',
        badge: '' + count
      },
      data: {
        mediaID: mediaID
      }
    };

    // Listing all tokens.
    const tokens = Object.keys(tokensSnapshot.val());

    // Send notifications to all tokens.
    return admin.messaging().sendToDevice(tokens, payload).then(response => {
      // For each message, check if there was an error.
      const tokensToRemove = [];
      response.results.forEach((result, index) => {
        const error = result.error;
        if (error) {
          console.error('Failure sending notifications to', tokens[index], error);
          // Cleanup the tokens who are not registered anymore.
          if (error.code === 'messaging/invalid-registration-token' ||
              error.code === 'messaging/registration-token-not-registered') {
                tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
          }
        }
      });
      return Promise.all(tokensToRemove);
    });

  })
});

// exports.sendNewForwardNotification = functions.database.ref('/mediaItems/{mediaID}/mapReference/{forwarder}').onWrite(event => {
//   const userID = event.params.userID;
//
//   const userID = admin.database().ref('/mediaItems')
// });

exports.sendNewInboxItemNotification = functions.database.ref('/users/{userID}/inbox/{inboxItem}').onCreate(event => {
  //   /users/{userID}/inbox/{itemID}/senderID/{senderID}
  const userID = event.params.userID;
  //const senderID = event.params.senderID;

  console.log('New inbox item sent to:', userID);

  // Get the list of device notification tokens.
  console.log('/users/' + userID + '/notificationToken');
  const getDeviceTokensPromise = admin.database().ref('/users/' + userID + '/notificationToken').once('value');
  const getBadgeCount = admin.database().ref('/users/' + userID + '/badgeCount').once('value');
  // Get the sender info
  //const getSenderInfoPromise = admin.auth().getUser(senderID);

  return Promise.all([getDeviceTokensPromise, getBadgeCount]).then(results => {
    const tokensSnapshot = results[0];
    const badgeSnapshot = results[1];
    //const senderSnapshot = results[1];
    var count = badgeSnapshot.val() + 1;
    console.log('COUNT', count);

    admin.database().ref('/users/' + userID + '/badgeCount').set(count);
    // Check if there are any device tokens.
    if (!tokensSnapshot.hasChildren()) {
      return console.log('There are no notification tokens to send to.');
    }

    console.log('There are', tokensSnapshot.numChildren(), 'tokens to send notifications to.');
    //console.log('Fetched sender info', senderSnapshot);

    // Notification details.
    const payload = {
      notification: {
        title: 'New Inbox Item',
        body: 'Go check it out!',
        //icon: senderSnapshot.photoURL,
        click_action: 'inbox',
        badge: '' + count
      }
    };

    // Listing all tokens.
    const tokens = Object.keys(tokensSnapshot.val());

    // Send notifications to all tokens.
    return admin.messaging().sendToDevice(tokens, payload).then(response => {
      // For each message, check if there was an error.
      const tokensToRemove = [];
      response.results.forEach((result, index) => {
        const error = result.error;
        if (error) {
          console.error('Failure sending notifications to', tokens[index], error);
          // Cleanup the tokens who are not registered anymore.
          if (error.code === 'messaging/invalid-registration-token' ||
              error.code === 'messaging/registration-token-not-registered') {
                tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
          }
        }
      });
      return Promise.all(tokensToRemove);
    });

  })
});
