import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ridesewa/BaseUrl.dart';

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

  // Fetch pending drivers from the backend
  Future<void> _fetchPendingDrivers() async {
    final token = await storage.read(key: 'auth_token');

    if (token == null) {
      print('Token is missing');
      setState(() {
        _loading = false;
        _errorOccurred = true;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/admin-dashboard/pending-drivers'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _drivers = json.decode(response.body);
          _loading = false;
        });
      } else {
        print('Error: Status code ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load drivers');
      }
    } catch (e) {
      print('Error fetching drivers: $e');
      setState(() {
        _loading = false;
        _errorOccurred = true;
      });
    }
  }

  // Verify a driver (approve or reject)
// Verify a driver (approve or reject)
Future<void> _verifyDriver(String driverId, bool isVerified) async {
  final token = await storage.read(key: 'auth_token');

  if (token == null) {
    print('Token is missing');
    setState(() {
      _errorOccurred = true;
    });
    Navigator.pushReplacementNamed(context, '/login');
    return;
  }

  try {
    final response = await http.post(
      Uri.parse('${BaseUrl.baseUrl}/api/admin/verify-driver'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'userId': driverId,  // Updated field name
        'isVerified': isVerified,
      }),
    );

    if (response.statusCode == 200) {
      _fetchPendingDrivers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Driver verification successful!')),
      );
    } else {
      print('Failed to update driver status: ${response.body}');
      throw Exception('Failed to update driver status');
    }
  } catch (e) {
    print('Error verifying driver: $e');
    setState(() {
      _errorOccurred = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error verifying driver. Please try again.')),
    );
  }
}


  // Build images from URLs or fallback error icon
  Widget _buildImage(String imagePath) {
    if (imagePath.isEmpty) {
      return Center(child: Icon(Icons.error, color: Colors.red, size: 40));
    }

    // Assuming imagePath might be a relative URL, you can prepend the base URL.
    String baseUrl = '${BaseUrl.baseUrl}';
    String imageUrl = imagePath.startsWith('http') ? imagePath : baseUrl + imagePath;

    return Image.network(
      imageUrl,
      height: 100,
      width: 200,
      fit: BoxFit.cover,
      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) {
          return child;
        } else {
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                  : null,
            ),
          );
        }
      },
      errorBuilder: (context, error, stackTrace) {
        return Center(child: Icon(Icons.error, color: Colors.red, size: 40));
      },
    );
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
                    return Card(
                      margin: EdgeInsets.all(10),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Driver ID: ${driver['id'] ?? 'N/A'}',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Text('First Name: ${driver['first_name'] ?? 'N/A'}'),
                            Text('Last Name: ${driver['last_name'] ?? 'N/A'}'),
                            Text('Email: ${driver['email'] ?? 'N/A'}'),
                            Text('Phone Number: ${driver['phone_number'] ?? 'N/A'}'),
                            Text('License Number: ${driver['license_number'] ?? 'N/A'}'),
                            Text('Citizenship ID: ${driver['citizenship_id'] ?? 'N/A'}'),
                            SizedBox(height: 8),
                            _buildImage(driver['license_photo']),
                            _buildImage(driver['citizenship_photo']),
                            _buildImage(driver['driver_photo']),
                            SizedBox(height: 12),
                            Text('Vehicle Type: ${driver['vehicle_type'] ?? 'N/A'}'),
                            Text('Vehicle Color: ${driver['vehicle_color'] ?? 'N/A'}'),
                            Text('Vehicle Number: ${driver['vehicle_number'] ?? 'N/A'}'),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.check, color: Colors.green),
                                  onPressed: () => _verifyDriver(driver['id'].toString(), true), // Ensure it's a String
                                ),
                                IconButton(
                                  icon: Icon(Icons.close, color: Colors.red),
                                  onPressed: () => _verifyDriver(driver['id'].toString(), false), // Ensure it's a String
                                ),
                              ],
                            )

                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
