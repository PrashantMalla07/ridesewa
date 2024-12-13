import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ridesewa/model/UserModel.dart';

class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  void setUser(User user) {
    _user = user;
    print('User set: ${_user?.uid}');
    notifyListeners();
  }

  // Method to refresh the user data from the API
  Future<void> refreshUser() async {
    try {
      final response = await http.get(Uri.parse('https://localhost:3000/api/user-profile'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _user = User.fromJson(data); // Assuming you have a fromJson constructor in your User class
        notifyListeners();
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }
}
