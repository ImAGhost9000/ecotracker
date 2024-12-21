import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:ecotracker/Providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecotracker/Providers/waterdevices_provider.dart';
import 'package:ecotracker/Providers/electricdevices_provider.dart';
import 'home_page.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  String _fullName = '';
  DateTime? _dateOfBirth;
  String _gender = '';
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isPasswordVisible = false; // For toggling password visibility

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Sign Up'),
          backgroundColor: Colors.green,
          leading: _currentStep > 0
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _currentStep--;
                    });
                  },
                )
              : null,
        ),
        body: Container(
          width: double.infinity, // Ensures the width spans the screen
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/nature.png'), // Add your image path
              fit: BoxFit.cover, // Ensure image covers the full background
            ),
          ),

          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 70),
                    // Logo
                    Image.asset(
                      'images/ecotracker_logo.png',
                      height: 100,
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 96, 96, 96),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Step indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(2, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: CircleAvatar(
                            radius: 7,
                            backgroundColor: _currentStep == index
                                ? Colors.green
                                : Colors.grey,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildCurrentStep(),
                          const SizedBox(height: 20),
                          // Next/Sign Up button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                              ),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  if (_currentStep < 1) {
                                    setState(() {
                                      _currentStep++;
                                      _clearTextFields();
                                    });
                                  } else {
                                    await createUserWithEmailAndPassword();
                                  }
                                }
                              },
                              child: Text(
                                _currentStep < 1 ? 'Next' : 'Sign Up',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight:
                                      FontWeight.bold, // Makes the text bold
                                  color: Colors
                                      .white, // Ensures high contrast with the green button
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  void _clearTextFields() {
    emailController.clear();
    passwordController.clear();
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = userCredential.user?.uid;

      // Save user details to Firestore
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'fullName': _fullName,
          'dateOfBirth': _dateOfBirth?.toIso8601String(),
          'gender': _gender,
          'email': emailController.text.trim(),
          'uid': uid, // Storing UID explicitly
          'createdAt': FieldValue.serverTimestamp(),
        });

        ref.read(currentUserUidProvider.notifier).state = uid;
        ref.read(waterDevicesListProvider.notifier).fetchDevices();
        ref.read(electricDevicesListProvider.notifier).fetchDevices();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (Route<dynamic> route) => false, // Removes all previous routes
        );
      }
    } on FirebaseAuthException catch (e) {
      print('Error: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'An error occurred')),
      );
    } catch (e) {
      print('Unexpected error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred')),
      );
    }
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildPersonalDetailsStep();
      case 1:
        return _buildAccountDetailsStep();
      default:
        return Container();
    }
  }

  Widget _buildPersonalDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextFormField(
          style: const TextStyle(
            fontSize: 16, // Same size as the label text
            fontWeight: FontWeight.normal, // Optional: match the label's weight
            color: Colors.white, // Same color as the label text
          ),
          decoration: const InputDecoration(
            labelText: 'Full Name',
            labelStyle: TextStyle(
              fontSize: 16, // Make the label larger
              fontWeight: FontWeight.normal, // Make the label text bold
              color:
                  Colors.white, // Darken the label color for better visibility
            ),
            fillColor: Color.fromARGB(99, 76, 73, 73),
            filled: true,
            border: OutlineInputBorder(),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? 'Enter your full name' : null,
          onSaved: (value) => _fullName = value!,
        ),
        const SizedBox(height: 15),
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() {
                _dateOfBirth = picked;
              });
            }
          },
          child: TextFormField(
            controller: TextEditingController(
                text: _dateOfBirth == null
                    ? ''
                    : _dateOfBirth!.toLocal().toString().split(' ')[0]),
            readOnly:
                true, // Make the text field read-only to open the calendar
            decoration: const InputDecoration(
              suffixIcon: Icon(
                Icons.calendar_today, // Calendar icon
                color: Colors.white, // Icon color
              ),
              fillColor: Color.fromARGB(99, 76, 73, 73),
              filled: true,
              border: OutlineInputBorder(),
              hintText: 'Date of Birth',
              hintStyle: TextStyle(
                fontSize: 16, // Font size for the placeholder
                color: Colors.white,
                fontWeight: FontWeight.normal, // Hint text color
              ),
            ),
            style: const TextStyle(
              fontSize: 16, // Font size for the input text
              color: Colors.white, // Text color
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select your date of birth';
              }
              return null; // Return null if validation passes
            },
            onTap: () async {
              // Implement date picker here to set the _dateOfBirth
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: _dateOfBirth ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null && pickedDate != _dateOfBirth) {
                setState(() {
                  _dateOfBirth = pickedDate;
                });
              }
            },
          ),
        ),
        const SizedBox(height: 15),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Gender',
            labelStyle: TextStyle(
              fontSize: 16, // Make the label larger
              fontWeight: FontWeight.normal, // Make the label text bold
              color:
                  Colors.white, // Darken the label color for better visibility
            ),
            fillColor: Color.fromARGB(99, 76, 73, 73),
            filled: true,
            border: OutlineInputBorder(),
          ),
          items: ['Male', 'Female', 'Other']
              .map((gender) =>
                  DropdownMenuItem(value: gender, child: Text(gender)))
              .toList(),
          onChanged: (value) => setState(() {
            _gender = value!;
          }),
          validator: (value) =>
              value == null || value.isEmpty ? 'Select your gender' : null,
        ),
      ],
    );
  }

  Widget _buildAccountDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextFormField(
          style: const TextStyle(
            fontSize: 16, // Same size as the label text
            fontWeight: FontWeight.normal, // Optional: match the label's weight
            color: Colors.white, // Same color as the label text
          ),
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            labelStyle: TextStyle(
              fontSize: 16, // Make the label larger
              fontWeight: FontWeight.normal, // Make the label text bold
              color:
                  Colors.white, // Darken the label color for better visibility
            ),
            fillColor: Color.fromARGB(55, 158, 158, 158),
            filled: true,
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Enter your email';
            }
            if (!RegExp(r'^[\w-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Invalid email address';
            }
            return null;
          },
        ),
        const SizedBox(height: 15),
        TextFormField(
          style: const TextStyle(
            fontSize: 16, // Same size as the label text
            fontWeight: FontWeight.normal, // Optional: match the label's weight
            color: Colors.white, // Same color as the label text
          ),
          controller: passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            labelStyle: const TextStyle(
              fontSize: 16, // Make the label larger
              fontWeight: FontWeight.normal, // Make the label text bold
              color:
                  Colors.white, // Darken the label color for better visibility
            ),
            fillColor: const Color.fromARGB(55, 158, 158, 158),
            filled: true,
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
          obscureText: !_isPasswordVisible,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Enter a password';
            }
            if (!RegExp(r'^(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
              return 'Password must contain an uppercase letter and a number';
            }
            return null;
          },
        ),
        const SizedBox(height: 15),
        TextFormField(
          style: const TextStyle(
            fontSize: 16, // Same size as the label text
            fontWeight: FontWeight.normal, // Optional: match the label's weight
            color: Colors.white, // Same color as the label text
          ),
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            labelStyle: const TextStyle(
              fontSize: 16, // Make the label larger
              fontWeight: FontWeight.normal, // Make the label text bold
              color:
                  Colors.white, // Darken the label color for better visibility
            ),
            fillColor: const Color.fromARGB(55, 158, 158, 158),
            filled: true,
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
          obscureText: !_isPasswordVisible,
          validator: (value) => value != passwordController.text
              ? 'Passwords do not match'
              : null,
        ),
      ],
    );
  }
}
