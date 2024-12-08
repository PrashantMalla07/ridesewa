import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  accountName: Text(
    driver?.name ?? 'Unknown Driver',
    style: TextStyle(color: Colors.black),
  ),
  accountEmail: Text(
    driver?.email ?? 'No email',
    style: TextStyle(color: Colors.black, fontSize: 15.0),
  ),
  currentAccountPicture: CircleAvatar(
    backgroundColor: Colors.white,
    backgroundImage: driver?.photoUrl.isNotEmpty ?? false
        ? NetworkImage(driver!.photoUrl) 
        : null,  // Use the photoUrl if available
    child: driver?.photoUrl.isEmpty ?? true
        ? Text(
            driver?.name.isNotEmpty ?? false ? driver!.name[0] : '',
            style: TextStyle(fontSize: 40.0, color: Colors.black),
          )
        : null, // Show the first letter if no photoUrl is available
  ),
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
                Navigator.pop(context);
                // Navigate to Trip History Page
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
                // Navigate to Help Page
              },
            ),
            ListTile(
              leading: const Icon(Icons.policy),
              title: const Text("Privacy Policy"),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Privacy Policy Page
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () {
                Navigator.pop(context);
                // Perform Logout Action
              },
            ),
          
        ],
      ),
    );
  }
}
