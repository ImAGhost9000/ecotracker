import 'package:flutter/material.dart';
import 'home_page.dart'; // Import HomePage class
void main() {
  runApp(const EcoTrackerApp());
}

class EcoTrackerApp extends StatelessWidget {
  const EcoTrackerApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(), // Adjust theme to match the dark layout
      home: const HomePage(), // Set HomePage as the initial route
    );
  }
}
