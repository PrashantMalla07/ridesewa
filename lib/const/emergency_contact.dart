import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContactPage extends StatelessWidget {
  // Emergency contact number
  final String emergencyNumber = '9816658815';
  // Emergency email
  final String emergencyEmail = 'prashantthakuree07@gmail.com';

  // Function to make a phone call
  Future<void> _makeCall(BuildContext context) async {
    final String phoneUrl = 'tel:$emergencyNumber';
    if (await canLaunch(phoneUrl)) {
      await launch(phoneUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch call')),
      );
    }
  }

  // Function to send email

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Emergency Contact Title
            Text(
              'Contact Emergency Support',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),

            // Call Button
            ElevatedButton.icon(
              onPressed: () => _makeCall(context),
              icon: Icon(Icons.call),
              label: Text('Call Emergency Support'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            SizedBox(height: 20),

            // Email Button
            ElevatedButton.icon(
              onPressed: () => (context),
              icon: Icon(Icons.email),
              label: Text('Email Emergency Support'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            SizedBox(height: 20),

            // Additional Info or Instructions
            Text(
              'For urgent support, please call the emergency number or send an email. We\'ll get back to you as soon as possible.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
