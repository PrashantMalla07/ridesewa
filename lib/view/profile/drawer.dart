import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/io_client.dart' as http;
import 'package:provider/provider.dart';
import 'package:ridesewa/provider/userprovider.dart';
import 'package:ridesewa/view/profile/profile_view.dart';
import 'package:ridesewa/view/profile/user_ride_history.dart';

class AppDrawer extends StatefulWidget {
  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    // Function to fetch user status
HttpClient createHttpClient() {
  final client = HttpClient();
  client.badCertificateCallback = (X509Certificate cert, String host, int port) => true; // Trust all certificates
  client.connectionTimeout = const Duration(seconds: 30); // Increase the timeout
  return client;
}
Future<void> checkUserStatus(BuildContext context) async {
  try {
    final ioClient = http.IOClient(createHttpClient());

    final response = await ioClient.post(
      Uri.parse('https://localhost:3000/api/user-status'),
      headers: {
        'Authorization': 'Bearer ${user?.token}', // Assuming you have a token for the authenticated user
     
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data.containsKey('isDriver') && data['isDriver'] != null) {
        final isDriver = data['isDriver'] == 1;
        final driverStatus = data['driverStatus'];
        final verificationDataFilled = data['verificationDataFilled'] == 1;

        if (isDriver && verificationDataFilled) {
          Navigator.pushReplacementNamed(context, '/driver-home');
        } else if (!isDriver && driverStatus == 'pending' && verificationDataFilled) {
          Navigator.pushReplacementNamed(context, '/waiting-for-approval');
        } else if (!isDriver && driverStatus == 'pending' && !verificationDataFilled) {
          Navigator.pushReplacementNamed(context, '/driver-verification');
        } else {
          print("Unexpected user status: isDriver: $isDriver, driverStatus: $driverStatus, verificationDataFilled: $verificationDataFilled");
        }
      } else {
        print("Response doesn't contain the 'isDriver' field.");
      }
    } else {
      print("Error: ${response.statusCode}");
    }
  } catch (error) {
    print('Error fetching user status: $error');
  }
}
void _logout(BuildContext context) {
  // Clear any session or token data here
  // For example, if you're using shared preferences or a similar package to store user data:
  
  // Example: Clear session or token
  // SharedPreferences.getInstance().then((prefs) {
  //   prefs.clear();  // Clear all stored data
  // });

  // Or if you're using a package like `flutter_secure_storage` to store tokens securely, clear it:
  // final storage = FlutterSecureStorage();
  // storage.delete(key: "user_token");

  // Now, navigate to the login page
  Navigator.pop(context);  // Close the drawer
  Navigator.pushReplacementNamed(context, '/login');  // Replace the current screen with Login page
}

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
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user?.firstName.isNotEmpty ?? false ? user!.firstName[0] : '',
                style: TextStyle(fontSize: 40.0, color: Colors.black),
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          const Divider(),

                  ListTile(
          leading: const Icon(Icons.dashboard),
          title: const Text("Dashboard"),
          onTap: () {
            Navigator.pop(context); // Close the drawer
            Navigator.pushReplacementNamed(context, '/home'); 
          },
        ),
       
        ListTile(
          leading: const Icon(Icons.history),
          title: const Text("Trip History"),
           onTap: () {
    Navigator.pop(context);

    // Access currentUser from the UserProvider
    final currentUser = Provider.of<UserProvider>(context, listen: false).user;

    if (currentUser != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RideHistoryScreen(userId: 1),  // Pass userId here
        ),
      );
    } else {
      // Handle the case where the user is null
      print("User not found.");
    }
  },
        ),
        ListTile(
          leading: const Icon(Icons.account_circle),
          title: const Text("Profile"),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileView()),
            );
          },
                ),
        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text("Reviews"),
          onTap: () {
            Navigator.pop(context);
            // Navigate to Notifications Page
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
            Navigator.pushNamed(context, '/help-support-passenger');
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
          // Perform Logout Action
          _logout(context);  // Call logout method
        },
        ),

        ],
      ),
    );
  }
}
