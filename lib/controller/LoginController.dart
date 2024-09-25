import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:ridesewa/model/UserModel.dart';
import 'package:ridesewa/provider/userprovider.dart';

class LoginController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String identifier = ''; // Can be email or phone number
  String password = '';

  final Dio dio = Dio(); // Ensure Dio is configured properly elsewhere
  final FlutterSecureStorage storage = FlutterSecureStorage();

Future<void> submitForm(BuildContext context) async {
    if (formKey.currentState!.validate()) {
        formKey.currentState!.save();

        print('User Login: $identifier');

        try {
            final response = await dio.post(
                'http://192.168.1.112:3000/login',
                options: Options(
                    headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8',
                    },
                ),
                data: jsonEncode(<String, String>{
                    'identifier': identifier,
                    'password': password,
                }),
            );

            print('Response Status: ${response.statusCode}');
            print('Response Body: ${response.data}');

            if (response.statusCode == 200) {
                final responseBody = response.data as Map<String, dynamic>;
                if (responseBody.containsKey('user') && responseBody.containsKey('token')) {
                    final user = User.fromJson(responseBody['user']);
                    final token = responseBody['token'];

                    // Save the user data and token
                    Provider.of<UserProvider>(context, listen: false).setUser(user);

                    // Store the token using FlutterSecureStorage
                    await storage.write(key: 'auth_token', value: token);

                    // Check if user is admin
                    if (user.isAdmin) {
                        Navigator.pushReplacementNamed(context, '/admin-dashboard');
                    } else {
                        Navigator.pushReplacementNamed(context, '/home');
                    }
                } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('User data or token not found in response')),
                    );
                }
            } else {
                final responseBody = response.data as Map<String, dynamic>;
                final errorMessage = responseBody['message'] ?? 'Login failed';
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(errorMessage)),
                );
            }
        } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('An error occurred: $e')),
            );
        }
    }
}



  String? validateIdentifier(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email or phone number';
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
