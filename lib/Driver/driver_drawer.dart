import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridesewa/const/trip_history.dart';
import 'package:ridesewa/provider/driverprovider.dart';

class DriverDrawer extends StatefulWidget {
  @override
  State<DriverDrawer> createState() => _DriverDrawerState();
}

class _DriverDrawerState extends State<DriverDrawer> {
  @override
  Widget build(BuildContext context) {
    final driver = Provider.of<DriverProvider>(context).driver;

    // Function to fetch driver status
    // ignore: unused_element
    HttpClient createHttpClient() {
      final client = HttpClient();
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true; // Trust all certificates
      client.connectionTimeout = const Duration(seconds: 30); // Increase the timeout
      return client;
    }

    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Row(
              children: [
                Text(
                  driver?.firstName ?? 'Unknown Driver',
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(width: 8.0),
                Text(
                  driver?.lastName ?? 'Unknown Driver',
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(width: 100.0),  // Add some space between name and UID
                Text(
                  'UID: ${driver?.uid ?? 'No UID'}',  // Display UID beside the name
                  style: TextStyle(color: Colors.black, fontSize: 14.0),
                ),
              ],
            ),
            accountEmail: Row(
              children: [
                Text(
                  driver?.email ?? 'No email',
                  style: TextStyle(color: Colors.black, fontSize: 15.0),
                ),
                 SizedBox(width: 40.0),  // Add some space between name and UID
                Text(
                  '${driver?.phoneNumber ?? 'No phone number'}',  // Display UID beside the name
                  style: TextStyle(color: Colors.black, fontSize: 14.0),
                ),
              ],
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: driver?.photoUrl?.isNotEmpty ?? false
                  ? NetworkImage(driver!.photoUrl)
                  : null,
              child: driver?.photoUrl?.isEmpty ?? true
                  ? Text(
                      driver?.firstName?.isNotEmpty ?? false ? driver!.firstName[0] : '',
                      style: TextStyle(fontSize: 40.0, color: Colors.black),
                    )
                  : null,
            ),
            otherAccountsPictures: [
              // Optional other accounts pictures (not needed for UID)
            ],
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
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
                Navigator.pop(context);
                // Navigate to Earnings Page
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
                Navigator.pop(context);
                // Navigate to Profile Page
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text("Notifications"),
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
  Navigator.pushReplacementNamed(context, '/driver-login');  // Replace the current screen with Login page
}
