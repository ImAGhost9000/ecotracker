import 'package:flutter/material.dart';
import 'home_page.dart'; // Import HomePage class
import 'package:flutter_riverpod/flutter_riverpod.dart';
void main() {
  runApp(const ProviderScope(child: MaterialApp(home: EcoTrackerApp())));
}



class EcoTrackerApp extends StatelessWidget {
  const EcoTrackerApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(), 
      home: const HomePage(), 
    );
  }
}
