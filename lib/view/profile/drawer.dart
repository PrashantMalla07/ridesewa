import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/io_client.dart' as http;
import 'package:provider/provider.dart';
import 'package:ridesewa/provider/userprovider.dart';

class AppDrawer extends StatefulWidget {
  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    // Function to fetch user status
    Future<void> checkUserStatus(BuildContext context) async {
      try {
        final client = HttpClient();
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true; // Allow all certificates

        final ioClient = http.IOClient(client);  // Use IOClient with the HttpClient

        final response = await ioClient.get(
          Uri.parse('https://localhost:3000/api/user-status'),
          headers: {
            'Authorization': 'Bearer ${user?.token}', // Assuming you have a token for the authenticated user
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          // Ensure that data contains 'isDriver' and 'driverStatus'
          if (data.containsKey('isDriver') && data['isDriver'] != null) {
            if (data['isDriver']) {
              // If the user is already a driver, navigate to the driver home page
              Navigator.pushReplacementNamed(context, '/driver-home');
            } else if (data.containsKey('driverStatus')) {
              if (data['driverStatus'] == 'pending') {
                // If the user has filled the form but approval is pending
                Navigator.pushReplacementNamed(context, '/waiting-for-approval');
              } else {
                // If the form isn't filled, navigate to the driver verification page
                Navigator.pushReplacementNamed(context, '/driver-verification');
              }
            } else {
              // If 'driverStatus' is missing, navigate to a default page or show an error
              print("Response doesn't contain 'driverStatus' field.");
            }
          } else {
            // Handle the case when 'isDriver' is not in the response
            print("Response doesn't contain the 'isDriver' field.");
          }
        } else {
          // Handle failed response (e.g., status code != 200)
          print("Error: ${response.statusCode}");
        }
      } catch (error) {
        // Handle network or other errors
        print('Error fetching user status: $error');
      }
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
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Change Password'),
            onTap: () {
              Navigator.pushNamed(context, '/change-password');
            },
          ),
          Spacer(),
          ListTile(
            leading: Icon(Icons.drive_eta),
            title: Text('Switch to Driver'),
            onTap: () {
              checkUserStatus(context);
            },
          ),
        ],
      ),
    );
  }
}
