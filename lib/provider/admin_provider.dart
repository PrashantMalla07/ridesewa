import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ridesewa/BaseUrl.dart';

class AdminProvider with ChangeNotifier {
  
  final _storage = const FlutterSecureStorage();
  String? _token;

  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${BaseUrl.baseUrl}/login'),
      body: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      _token = jsonDecode(response.body)['token'];
      await _storage.write(key: 'admin_token', value: _token);
      notifyListeners();
      return true;
    }

    return false;
  }

  Future<List<dynamic>> fetchDrivers() async {
    final token = await _storage.read(key: 'admin_token');
    final response = await http.get(
      Uri.parse('${BaseUrl.baseUrl}/admin/drivers'),
      headers: {'Authorization': token!},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to fetch drivers');
  }

  Future<void> addDriver(Map<String, String> driverData) async {
    final token = await _storage.read(key: 'admin_token');
    final response = await http.post(
      Uri.parse('${BaseUrl.baseUrl}/admin/drivers'),
      headers: {'Authorization': token!},
      body: driverData,
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add driver');
    }
  }

  Future<void> updateDriver(String id, Map<String, String> driverData) async {
    final token = await _storage.read(key: 'admin_token');
    final response = await http.put(
      Uri.parse('${BaseUrl.baseUrl}/admin/drivers/$id'),
      headers: {'Authorization': token!},
      body: driverData,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update driver');
    }
  }

  Future<void> deleteDriver(String id) async {
    final token = await _storage.read(key: 'admin_token');
    final response = await http.delete(
      Uri.parse('${BaseUrl.baseUrl}/admin/drivers/$id'),
      headers: {'Authorization': token!},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete driver');
    }
  }
}
