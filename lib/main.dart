import 'package:flutter/material.dart';
import 'home_page.dart'; // Import HomePage class
void main() {
  runApp(EcoTrackerApp());
}

class EcoTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(), // Adjust theme to match the dark layout
      home: HomePage(), // Set HomePage as the initial route
    );
  }
}
