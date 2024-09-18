import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String identifier = ''; // Can be email or phone number
  String password = '';

  // Function to validate and submit the form
  Future<void> submitForm(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      // Print user data (for debugging purposes)
      print('User Login: $identifier');

      try {
        final response = await http.post(
          Uri.parse('http://192.168.1.112:3000/login'), // Your API endpoint
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'identifier': identifier, // Use 'identifier' for email or phone number
            'password': password,
          }),
        );

        if (response.statusCode == 200) {
          // Login successful
          final responseBody = jsonDecode(response.body);
          // Check if the response has a success message
          final message = responseBody['message'] ?? 'Login successful';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
          // Navigate to home page or other screen
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          // Handle server errors or validation errors
          final responseBody = jsonDecode(response.body);
          final errorMessage = responseBody['message'] ?? 'Login failed';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      } catch (e) {
        // Handle network or other errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    }
  }

  // Validators for each field
  String? validateIdentifier(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email or phone number';
    }
    // Additional validation can be added if needed (e.g., email format check)
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty || value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}
