import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:ridesewa/BaseUrl.dart';
import 'package:ridesewa/provider/userprovider.dart';
import 'package:ridesewa/view/profile/profile_view.dart';
import 'package:ridesewa/view/profile/settings.dart';
import 'package:ridesewa/view/profile/user_review.dart';
import 'package:ridesewa/view/profile/user_ride_history.dart';

class AppDrawer extends StatefulWidget {
  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  double? _averageRating;
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _fetchAverageUserRating();
    _fetchUserProfile();
  }

  // Custom HTTP client to bypass SSL errors
  HttpClient createHttpClient() {
    final client = HttpClient();
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    client.connectionTimeout = const Duration(seconds: 30);
    return client;
  }

  // Fetch the average user rating
  Future<void> _fetchAverageUserRating() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final String? userId = userProvider.user?.id.toString();
    if (userId == null) {
      setState(() {
        _errorMessage = 'User ID is not available.';
        _isLoading = false;
      });
      return;
    }

    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await _dio.get(
        '${BaseUrl.baseUrl}/api/user_ratings/user/$userId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        final dynamic averageRating = response.data['average_rating'];
        if (averageRating is num || (averageRating is String && double.tryParse(averageRating) != null)) {
          setState(() {
            _averageRating = double.parse(averageRating.toString())?? 5.0;
            _isLoading = false;
          });
        } else {
          throw Exception('Invalid average rating value');
        }
      } else {
        throw Exception('Failed to load average rating with status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load average rating. Please try again later. Error: $e';
        _isLoading = false;
      });
    }
  }
  Future<void> _fetchUserProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final String? userId = userProvider.user?.id.toString();
    if (userId == null) {
      setState(() {
        _errorMessage = 'User ID is not available.';
        _isLoading = false;
      });
      return;
    }

    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await _dio.get(
        '${BaseUrl.baseUrl}/user/profile/$userId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      setState(() {
        _userData = response.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile. Please try again later.';
        _isLoading = false;
      });
    }
  }
Widget _buildPlaceholderProfile() {
  return CircleAvatar(
    backgroundColor: Colors.grey, // Placeholder color
    child: Icon(Icons.person, size: 40.0, color: Colors.white),
  );
}
  // Handle logout action
  void _logout(BuildContext context) {
    // Clear any session or token data
    _storage.delete(key: 'auth_token'); // Clear auth token
    Navigator.pop(context); // Close the drawer
    Navigator.pushReplacementNamed(context, '/login'); // Navigate to login
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(
              '${user?.firstName ?? ''} ${user?.lastName ?? ''}',
              style: TextStyle(color: Colors.black),
            ),
            accountEmail: Text(
              user?.email ?? '',
              style: TextStyle(color: Colors.black, fontSize: 15.0),
            ),
                       currentAccountPicture: ClipOval(
  child: _userData != null && _userData!['image_url'] != null &&
          _userData!['image_url'].isNotEmpty
      ? Image.network(
          _userData!['image_url'],
          height: 150.0,
          width: 150.0,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholderProfile();
          },
        )
      : _buildPlaceholderProfile(),
),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            title: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(child: Text(_errorMessage))
                    : _averageRating != null
                        ? Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.yellow,
                                size: 30,
                              ),
                              SizedBox(width: 8),
                              Text(
                  _averageRating != null
                      ? '$_averageRating'
                      : '5.0', // Show default rating if no data
                ),
                            ],
                          )
                        : Center(child: Text('No rating data available')),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text("Home"),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("Trip History"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserRideHistory(),  // Navigate to ride history page
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text("Profile"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfilePage(),  // Navigate to profile page
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text("Reviews"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserReviewPage(),  // Navigate to reviews page
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {
               Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(),  // Navigate to reviews page
                ),);
            },
          ),
          Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.support_agent),
            title: const Text("Help & Support"),
            onTap: () {
              Navigator.pop(context);  // Close the drawer
              Navigator.pushNamed(context, '/help-support-passenger');  // Navigate to support page
            },
          ),
          ListTile(
            leading: const Icon(Icons.policy),
            title: const Text("Privacy Policy"),
            onTap: () {
              Navigator.pop(context);  // Close the drawer
              Navigator.pushNamed(context, '/privacy-policy');  // Navigate to privacy policy page
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () {
              _logout(context);  // Perform logout action
            },
          ),
        ],
      ),
    );
  }
}
