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
