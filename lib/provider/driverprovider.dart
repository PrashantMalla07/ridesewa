import 'package:flutter/material.dart';

  // Import your Driver class

class DriverProvider with ChangeNotifier {
  Driver _driver;

  DriverProvider({required Driver driver}) : _driver = driver;

  // Getter for the driver
  Driver get driver => _driver;

  // Method to update driver data (if needed)
  void updateDriverInfo(Driver newDriver) {
    _driver = newDriver;
    notifyListeners();  // Notify listeners when the driver data changes
  }
}
class Driver {
  final bool isDriver;
  final bool isDriverVerified;

  Driver({
    required this.isDriver,
    required this.isDriverVerified,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      isDriver: json['isDriver'] ?? false,
      isDriverVerified: json['isDriverVerified'] ?? false,
    );
  }
}