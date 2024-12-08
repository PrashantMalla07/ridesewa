import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ridesewa/model/DriverModel.dart';

class DriverProvider with ChangeNotifier {
  Driver? _driver;

  Driver? get driver => _driver;

  // This method sets the driver state from a parsed Driver object
  void setDriver(Driver driver) {
    _driver = driver;
    notifyListeners();
  }

  // This method fetches driver details from the backend API
  Future<void> fetchDriverDetails() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/api/drivers/details'));

      if (response.statusCode == 200) {
        // Parse the response body and set the driver
        final Map<String, dynamic> data = json.decode(response.body);
        final driver = Driver.fromJson(data); // Use the model's fromJson method
        setDriver(driver);
      } else {
        throw Exception('Failed to load driver details');
      }
    } catch (error) {
      throw Exception('Error fetching driver details: $error');
    }
  }
}
