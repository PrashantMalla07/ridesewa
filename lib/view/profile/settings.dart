import 'package:flutter/material.dart';
import 'package:ridesewa/view/profile/update_profile.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue, // Adjust color as needed
        elevation: 4.0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent.withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          children: <Widget>[
            // Edit Profile
            _buildListTile(
              icon: Icons.person,
              title: 'Edit Profile',
              iconColor: Colors.blue,
              onTap: () {
                
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfilePage()),
                );
              },
            ),
            _buildDivider(),

            // Change Profile Image
            _buildListTile(
              icon: Icons.image,
              title: 'Change Profile Image',
              iconColor: Colors.blue,
              onTap: () {
                // Navigate to Change Profile Image Page (Uncomment when implemented)
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => ChangeProfileImagePage()),
                // );
              },
            ),
            _buildDivider(),

            // Change Password
            _buildListTile(
              icon: Icons.lock,
              title: 'Change Password',
              iconColor: Colors.blue,
              onTap: () {
                // Navigate to Change Password Page (Uncomment when implemented)
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => ChangePasswordPage()),
                // );
              },
            ),
            _buildDivider(),

            // Logout Option
            _buildListTile(
              icon: Icons.logout,
              title: 'Logout',
              iconColor: Colors.red,
              onTap: () {
                _logout(context); // Handle logout
              },
              isLogout: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isLogout ? Colors.red.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          leading: CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.2),
            child: Icon(icon, color: iconColor),
          ),
          title: Text(
            title,
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
          ),
          trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey.withOpacity(0.4),
      height: 2,
      thickness: 1,
    );
  }

  // Logout method
  void _logout(BuildContext context) {
    // Clear any session or token data here
    // Example: FlutterSecureStorage().delete(key: 'auth_token');
    
    // Navigate to login page
    Navigator.pushReplacementNamed(context, '/login');
  }
}
