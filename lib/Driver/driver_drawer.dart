import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:ridesewa/const/driver_profile_page.dart';
import 'package:ridesewa/const/driver_review.dart';
import 'package:ridesewa/const/earnings.dart';
import 'package:ridesewa/const/trip_history.dart';
import 'package:ridesewa/provider/driverprovider.dart';

class DriverDrawer extends StatefulWidget {
  @override
  State<DriverDrawer> createState() => _DriverDrawerState();
}

class _DriverDrawerState extends State<DriverDrawer> {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  double? _averageRating;
  bool _isLoading = true;
  String _errorMessage = '';
   Map<String, dynamic>? _driverData;

  @override
  void initState() {
    super.initState();
    _fetchAverageDriverRating();
    _fetchDriverProfile();
  }
 Future<void> _fetchDriverProfile() async {
    final driverProvider = Provider.of<DriverProvider>(context, listen: false);
    final String? driveruid = driverProvider.driver?.uid?.toString();
    if (driveruid == null) {
      setState(() {
        _errorMessage = 'Driver UID is not available.';
        _isLoading = false;
      });
      return;
    }

    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await _dio.get(
        'http://localhost:3000/driver/profile/$driveruid',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      setState(() {
        _driverData = response.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile. Please try again later.';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchAverageDriverRating() async {
    final driverProvider = Provider.of<DriverProvider>(context, listen: false);
    final String? driverUid = driverProvider.driver?.uid?.toString();
    if (driverUid == null) {
      setState(() {
        _errorMessage = 'Driver UID is not available.';
        _isLoading = false;
      });
      return;
    }

    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await _dio.get(
        'http://localhost:3000/api/driver_ratings/driver/$driverUid',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        final dynamic averageRating = response.data['average_rating'];
        if (averageRating is num || (averageRating is String && double.tryParse(averageRating) != null)) {
          setState(() {
            _averageRating = double.parse(averageRating.toString());
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

Widget _buildPlaceholderProfile() {
  return CircleAvatar(
    backgroundColor: Colors.grey, // Placeholder color
    child: Icon(Icons.person, size: 40.0, color: Colors.white),
  );
}
  @override
  Widget build(BuildContext context) {
    final driver = Provider.of<DriverProvider>(context).driver;

    // Handle case where driver is null
    if (driver == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Driver Drawer")),
        body: Center(child: Text("Driver data is not available")),
      );
    }

    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Row(
              children: [
                Text(
                  driver.firstName ?? 'Unknown Driver',
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(width: 8.0),
                Text(
                  driver.lastName ?? 'Unknown Driver',
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(width: 100.0),  // Add some space between name and UID
                Text(
                  'UID: ${driver.uid ?? 'No UID'}',  // Display UID beside the name
                  style: TextStyle(color: Colors.black, fontSize: 14.0),
                ),
              ],
            ),
            accountEmail: Row(
              children: [
                Text(
                  driver.email ?? 'No email',
                  style: TextStyle(color: Colors.black, fontSize: 15.0),
                ),
                SizedBox(width: 40.0),  // Add some space between name and UID
                Text(
                  driver.phoneNumber ?? 'No phone number',  // Display phone number
                  style: TextStyle(color: Colors.black, fontSize: 14.0),
                ),
              ],
            ),
            currentAccountPicture: ClipOval(
  child: _driverData != null && _driverData!['driver_photo'] != null &&
          _driverData!['driver_photo'].isNotEmpty
      ? Image.network(
          _driverData!['driver_photo'],
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

          // Display average rating below the email and phone number
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
                                color: Colors.yellow, // Yellow star
                                size: 30, // Larger star size
                              ),
                              SizedBox(width: 8), // Space between the star and the rating
                              Text('$_averageRating'),
                            ],
                          )
                        : Center(child: Text('No rating data available')),
          ),

          const Divider(),

          // Navigation Items
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text("Dashboard"),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              // Navigate to Dashboard
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text("Earnings"),
            onTap: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DriverEarningsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("Trip History"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RideHistoryDrawer()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_copy),
            title: const Text("Profile & Documents"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DriverProfilePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text("Reviews"),
            onTap: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DriverReviewPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {
              Navigator.pop(context);
              // Navigate to Settings Page
            },
          ),

          Spacer(),
          const Divider(),

          // Support and Legal
          ListTile(
            leading: const Icon(Icons.support_agent),
            title: const Text("Help & Support"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/help-support');
            },
          ),
          ListTile(
            leading: const Icon(Icons.policy),
            title: const Text("Privacy Policy"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/privacy-policy');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () {
              _logout(context);
            },
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    // Clear any session or token data here
    // Example: Clear session or token
    // SharedPreferences.getInstance().then((prefs) {
    //   prefs.clear();  // Clear all stored data
    // });

    // Or if you're using a package like `flutter_secure_storage` to store tokens securely, clear it:
    // final storage = FlutterSecureStorage();
    // storage.delete(key: "user_token");

    // Now, navigate to the login page
    Navigator.pop(context);  // Close the drawer
    Navigator.pushReplacementNamed(context, '/driver-login');  // Replace the current screen with Login page
  }
}
