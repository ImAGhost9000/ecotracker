import 'package:flutter/material.dart';
import 'login_page.dart'; // Ensure the login_page.dart file exists and is correct
import 'home_page.dart';  // Import the HomePage

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()), // Navigate to HomePage
            );
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // This will push content to the top and bottom
        children: [
          // Add your icons or other settings options here
          const Expanded(
            child: Center(
              child: Text(
                'Settings Page', // Replace with your settings options or icons
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0), // Add some padding for aesthetics
            child: ElevatedButton(
              onPressed: () {
                // Navigate back to the login page when logging out
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false, // This will remove all routes from the stack
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }
}
