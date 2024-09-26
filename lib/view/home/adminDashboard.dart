import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<dynamic> _drivers = [];
  bool _loading = true;
  bool _errorOccurred = false;
  final FlutterSecureStorage storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _fetchPendingDrivers();
  }

  Future<void> _fetchPendingDrivers() async {
    final token = await storage.read(key: 'auth_token');
    
    if (token == null) {
      // Handle missing token: maybe redirect to login page
      print('Token is missing');
      setState(() {
        _loading = false;
        _errorOccurred = true;
      });
      // Optionally navigate to login
      // Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/admin-dashboard/pending-drivers'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Successfully fetched pending drivers
        setState(() {
          _drivers = json.decode(response.body);
          _loading = false;
        });
      } else {
        // Server responded with an error
        print('Error: Status code ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load drivers');
      }
    } catch (e) {
      // Log the exception for better debugging
      print('Error fetching drivers: $e');
      setState(() {
        _loading = false;
        _errorOccurred = true;
      });
    }
  }

  Future<void> _verifyDriver(int userId, bool isVerified) async {
    final token = await storage.read(key: 'auth_token');
    
    if (token == null) {
      print('Token is missing');
      setState(() {
        _errorOccurred = true;
      });
      // Optionally navigate to login
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/admin/verify-driver'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userId': userId,
          'isVerified': isVerified,
        }),
      );

      // Debugging the response for easier troubleshooting
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        _fetchPendingDrivers(); // Refresh the list after verification
      } else {
        print('Failed to update driver status: ${response.body}');
        throw Exception('Failed to update driver status');
      }
    } catch (e) {
      print('Error verifying driver: $e');
      setState(() {
        _errorOccurred = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _errorOccurred
              ? Center(child: Text('An error occurred. Please try again later.'))
              : ListView.builder(
                  itemCount: _drivers.length,
                  itemBuilder: (context, index) {
                    final driver = _drivers[index];
                    return ListTile(
                      title: Text('User ID: ${driver['user_id']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('License Number: ${driver['license_number']}'),
                          Text('Citizenship ID: ${driver['citizenship_id']}'),
                          driver['license_photo'] != null
                              ? Image.network(driver['license_photo'], height: 100)
                              : SizedBox.shrink(),
                          driver['citizenship_photo'] != null
                              ? Image.network(driver['citizenship_photo'], height: 100)
                              : SizedBox.shrink(),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.check, color: Colors.green),
                            onPressed: () => _verifyDriver(driver['user_id'], true),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.red),
                            onPressed: () => _verifyDriver(driver['user_id'], false),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
