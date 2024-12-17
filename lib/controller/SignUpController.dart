import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ridesewa/BaseUrl.dart';
import 'package:ridesewa/model/UserModel.dart';

class SignUpController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // This holds the user data
  UserModel user = UserModel(
    firstName: '',
    lastName: '',
    email: '',
    password: '',
    phoneNumber: '', 
  );

  // Function to validate and submit the form
  Future<void> submitForm(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      // Debugging: Print user data
      print('User Signed Up: ${user.firstName} ${user.lastName}');

      try {
        // Send a POST request to the backend
        final response = await http.post(
          Uri.parse('${BaseUrl.baseUrl}/register'), 
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'first_name': user.firstName,
            'last_name': user.lastName,
            'phone_number': user.phoneNumber,
            'email': user.email,
            'password': user.password,
          }),
        );

        if (response.statusCode == 201) {
          // If registration is successful
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration successful')),
          );

          // Navigate to login page or another page
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          // Handle different response errors or validation errors
          final responseBody = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseBody['message'] ?? 'Registration failed')),
          );
        }
      } catch (e) {
        // Handle any errors during the request
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    }
  }

  // Validators for each field
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a name';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty || !value.contains('@')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty || value.length != 10) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty || value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}
