import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:ridesewa/BaseUrl.dart';
import 'package:ridesewa/model/DriverModel.dart'; // Adjust import for your DriverModel
import 'package:ridesewa/provider/driverprovider.dart'; // Adjust to a provider for Driver data

class DriverLoginController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String identifier = ''; // Can be email or phone number
  String password = '';

  final Dio dio = Dio(); // Ensure Dio is configured properly elsewhere
  final FlutterSecureStorage storage = FlutterSecureStorage();

  Future<void> driverSubmitForm(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      print('Driver Login: $identifier');
      print('Password: $password');

      try {
        final response = await dio.post(
          '${BaseUrl.baseUrl}/api/driver-login',
          options: Options(
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
          ),
          data: jsonEncode(<String, String>{
            'email': identifier.isValidEmail() ? identifier : '',  // Send only if valid email
            'phoneNumber': identifier.isValidPhoneNumber() ? identifier : '',  // Send only if valid phone number
            'password': password,
          }),
        );

        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.data}');

        if (response.statusCode == 200) {
          final responseBody = response.data as Map<String, dynamic>;

          if (responseBody.containsKey('driver')) {
            final driverData = responseBody['driver']; // Ensure the correct field name from backend
            print('Parsed Driver Data: $driverData');
            final driver = Driver.fromJson(driverData);

            print('Parsed User:  ${driver.firstName}, ${driver.email}, ${driver.phoneNumber}, ${driver.uid},');
            Provider.of<DriverProvider>(context, listen: false).setDriver(driver);

            // Proceed to next screen
            Navigator.pushReplacementNamed(context, '/driver-home');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Driver data not found in response')));
          }
        } else {
          final responseBody = response.data as Map<String, dynamic>;
          final errorMessage = responseBody['message'] ?? 'Login failed';
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
        }

      } catch (e) {
        if (e is DioError) {
          print('Dio error: ${e.message}');
          if (e.response != null) {
            print('Status code: ${e.response?.statusCode}');
            print('Response data: ${e.response?.data}');
          }
        } else {
          print('Unexpected error: $e');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: ${e.toString()}')),
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

extension on String {
  bool isValidEmail() {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(this);
  }

  bool isValidPhoneNumber() {
    final phoneRegex = RegExp(r'^\d{10}$'); // Adjust the pattern as needed for phone number format
    return phoneRegex.hasMatch(this);
  }
}
