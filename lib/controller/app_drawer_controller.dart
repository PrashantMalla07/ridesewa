// lib/controllers/app_drawer_controller.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AppDrawerController extends ChangeNotifier {
  String username = '';
  String email = '';
  String phoneNumber = '';

  Future<void> fetchUserData(String token) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/users/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        username = data['username'];
        email = data['email'];
        phoneNumber = data['phoneNumber'];
        notifyListeners();
      } else {
        print('Failed to load user data');
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }
}
