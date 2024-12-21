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
      "title": "Shower",
      "usagePerUse": 2.1,
      "color": "#FF0000",
    },
    {
      "id": 2,
      "title": "Washing Machine",
      "usagePerUse": 5.0,
      "color": "#0000FF",
    },
    {
      "id": 3,
      "title": "Toilet",
      "usagePerUse": 3.0,
      "color": "#FFFF00",
    },
    {
      "id": 4,
      "title": "Dishwasher",
      "usagePerUse": 4.0,
      "color": "#008000",
    },
  ];

  final collection = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('water_devices');

  for (var device in devices) {
    final doc = collection.doc(device['id'].toString());
    final exists = await doc.get();

    if (!exists.exists) {
      await doc.set(device);
    }
  }
}
