import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void seedPredefinedDevices() async {
  // Get the current user from FirebaseAuth
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    // Get the user ID (UID) of the logged-in user
    final userId = user.uid;

    // Call the function with the user ID
    _seedDevicesForUser(userId);
  } else {
    print("No user is logged in");
  }
}

void _seedDevicesForUser(String userId) async {
  final devices = [
    {
      "id": 1,
      "title": "Air Conditioner",
      "usagePerUse": 3.5,
      "color": "#FF0000",
    },
    {
      "id": 2,
      "title": "Washing Machine",
      "usagePerUse": 0.8,
      "color": "#0000FF",
    },
    {
      "id": 3,
      "title": "Lights",
      "usagePerUse": 3.0,
      "color": "#FFFF00",
    },
    {
      "id": 4,
      "title": "Computer",
      "usagePerUse": 0.42,
      "color": "#008000",
    },
    {
      "id": 5,
      "title": "Phones",
      "usagePerUse": 0.35,
      "color": "#FFC0CB",
    },
  ];

  // Reference to the user's subcollection
  final collection = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('electric_devices');

  for (var device in devices) {
    final doc = collection.doc(device['id'].toString());
    final exists = await doc.get();

    if (!exists.exists) {
      await doc.set(device);
    }
  }
}
