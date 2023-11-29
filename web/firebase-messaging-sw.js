// Give the service worker access to Firebase Messaging.
// Note that you can only use Firebase Messaging here. Other Firebase libraries
// are not available in the service worker.
importScripts('https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js');

// Initialize the Firebase app in the service worker by passing in
// your app's Firebase config object.
// https://firebase.google.com/docs/web/setup#config-object

const firebaseConfig = {
    apiKey: "AIzaSyBHu-WMcqS7znrMYh3drREMseFw7O-Pp2A",
    authDomain: "kindahclothing.firebaseapp.com",
    projectId: "kindahclothing",
    storageBucket: "kindahclothing.appspot.com",
    messagingSenderId: "3440730765",
    appId: "1:3440730765:web:07a99ac7848dd219dab8c4",
    measurementId: "G-EYKR8RQCZW"
};

firebase.initializeApp(firebaseConfig);

// Retrieve an instance of Firebase Messaging so that it can handle background
// messages.
const messaging = firebase.messaging();