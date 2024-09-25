import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridesewa/provider/userprovider.dart';

class AppDrawer extends StatelessWidget {
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
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user?.firstName.isNotEmpty ?? false ? user!.firstName[0] : '',
                style: TextStyle(fontSize: 40.0, color: Colors.black),
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.blue, // Set the background color to sky blue
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
          Spacer(), // Pushes the next ListTile to the bottom
          ListTile(
            leading: Icon(Icons.drive_eta),
            title: Text('Switch to Driver'),
            onTap: () {
              // Add functionality to switch user role to driver
              Navigator.pushNamed(context, '/driver-verification'); 
            },
          ),
        ],
      ),
    );
  }
}
