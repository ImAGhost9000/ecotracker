import 'package:flutter/material.dart';

void showConfirmedSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.transparent, // Remove default background color
      behavior: SnackBarBehavior.floating, // Make it float above the content
      content: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.green[900], // Background color of the circle
          borderRadius: BorderRadius.circular(30.0), // Make it circular
        ),
        child: Center(
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white, // Text color
              fontSize: 16.0,
              fontWeight: FontWeight.bold, // Text weight
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      duration: const Duration(seconds: 2), // How long the SnackBar stays
    ),
  );
}

void showErrorSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
      content: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.red[900],
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Center(
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      duration: const Duration(seconds: 2), // How long the SnackBar stays
    ),
  );
}
