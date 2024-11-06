import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'home_page.dart'; // Import HomePage class



class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _fullName = '';
  DateTime? _dateOfBirth;
  String _gender = '';
  String _password = '';
  String _confirmPassword = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: _currentStep > 0
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _currentStep--;
                  });
                },
              )
            : null,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              Center(
                child: Image.asset(
                  'images/ecotracker_logo.png',
                  height: 120,
                ),
              ),
              SizedBox(height: 20),
              Text(
                _currentStep < 5 ? 'Create Account' : 'Log in',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              _buildProgressIndicator(),
              SizedBox(height: 20),
              Form(
                key: _formKey,
                child: _buildCurrentStep(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text(_currentStep < 5 ? 'Continue' : 'Login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    setState(() {
                      if (_currentStep < 5) {
                        _currentStep++;
                      } else {
                        print('Logging in with email: $_email');
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      }
                    });
                  }
                },
              ),
              SizedBox(height: 10),
              _buildSocialSignIn(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        5,
        (index) => Container(
          width: 10,
          height: 10,
          margin: EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index <= _currentStep ? Colors.green : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildEmailStep();
      case 1:
        return _buildFullNameStep();
      case 2:
        return _buildDateOfBirthStep();
      case 3:
        return _buildGenderStep();
      case 4:
        return _buildPasswordStep();
      case 5:
        return _buildLoginStep();
      default:
        return Container();
    }
  }

  Widget _buildEmailStep() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Email',
        filled: true,
        fillColor: Colors.grey[800],
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        // Regular expression for validating email format
        if (!RegExp(r'^[\w-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email (e.g. example@domain.com)';
        }
        return null;
      },
      onSaved: (value) {
        _email = value!;
        // Reset full name after email input
        _fullName = '';
      },
    );
  }

  Widget _buildFullNameStep() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Your Full Name',
        filled: true,
        fillColor: Colors.grey[800],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your full name';
        }
        return null;
      },
      onSaved: (value) => _fullName = value!,
    );
  }

  Widget _buildDateOfBirthStep() {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _dateOfBirth ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() {
            _dateOfBirth = picked;
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date of Birth',
          filled: true,
          fillColor: Colors.grey[800],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(_dateOfBirth == null
                ? 'Select Date'
                : DateFormat('yyyy-MM-dd').format(_dateOfBirth!)),
            Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderStep() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Gender',
        filled: true,
        fillColor: Colors.grey[800],
      ),
      items: ['Male', 'Female', 'Other'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _gender = value!;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select your gender';
        }
        return null;
      },
      onSaved: (value) => _gender = value!,
    );
  }

  Widget _buildPasswordStep() {
    return Column(
      children: [
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Password',
            filled: true,
            fillColor: Colors.grey[800],
          ),
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a password';
            }
            // Password must contain at least one capital letter and one number
            if (!RegExp(r'^(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
              return 'Password must contain at least one capital letter and one number';
            }
            return null;
          },
          onChanged: (value) => _password = value,
          onSaved: (value) => _password = value!,
        ),
        SizedBox(height: 10),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            filled: true,
            fillColor: Colors.grey[800],
          ),
          obscureText: true,
          validator: (value) {
            if (value != _password) {
              return 'Passwords do not match';
            }
            return null;
          },
          onSaved: (value) => _confirmPassword = value!,
        ),
      ],
    );
  }

  Widget _buildLoginStep() {
    return Column(
      children: [
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Email',
            filled: true,
            fillColor: Colors.grey[800],
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
          onSaved: (value) => _email = value!,
        ),
        SizedBox(height: 10),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Password',
            filled: true,
            fillColor: Colors.grey[800],
          ),
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            return null;
          },
          onSaved: (value) => _password = value!,
        ),
      ],
    );
  }

  Widget _buildSocialSignIn() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Image.asset('images/google_icon.png', height: 24),
          onPressed: () {
            // Handle Google sign-in
          },
        ),
        IconButton(
          icon: Image.asset('images/facebook_icon.png', height: 24),
          onPressed: () {
            // Handle Facebook sign-in
          },
        ),
      ],
    );
  }
}
