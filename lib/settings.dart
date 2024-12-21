import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({Key? key}) : super(key: key);

  // Function to fetch user details from Firestore
  Future<Map<String, dynamic>?> getUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return doc.data();
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 24, // Make the text bigger
            fontWeight: FontWeight.bold, // Optional: make it bold
          ),
        ),
        backgroundColor: const Color(0xFF6A9C89),
        centerTitle: false, // Align the title to the left
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading user details'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No user details available'));
          }

          final userDetails = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: [
                // Top Profile Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF16423C),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        userDetails['fullName'] ?? 'Name not set',
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        userDetails['email'] ?? 'Email not set',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                // User Info Section
                const SizedBox(height: 20),
                _buildUserInfoTile(
                  icon: Icons.cake,
                  title: 'Birthday',
                  value: _formatDate(userDetails['dateOfBirth']) ?? 'Not set',
                ),

                _buildUserInfoTile(
                  icon: userDetails['gender'] == 'Female'
                      ? Icons.female
                      : Icons.male, // Change icon based on gender
                  title: 'Gender',
                  value: userDetails['gender'] ?? 'Not set',
                ),

                const Divider(height: 40, thickness: 1),

                // Settings Options
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.green),
                  title: const Text('Account Settings'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navigate to account settings
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.exit_to_app, color: Colors.red),
                  title: const Text(
                    'Sign Out',
                    style: TextStyle(
                      color: Colors.red, // Make the text red
                      fontWeight: FontWeight
                          .bold, // Optional: make it bold for emphasis
                    ),
                  ),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String? _formatDate(String? date) {
    if (date == null) return null;
    try {
      final DateTime parsedDate =
          DateTime.parse(date); // If it's a string in a recognizable format
      final DateFormat formatter =
          DateFormat('MMMM dd, yyyy'); // Desired format
      return formatter.format(parsedDate); // Format and return
    } catch (e) {
      return date; // Return the original date if parsing fails
    }
  }

  // Helper widget to display user info
  Widget _buildUserInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 17.5, color: Colors.white),
      ),
    );
  }
}
