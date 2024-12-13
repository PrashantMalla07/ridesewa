import 'package:flutter/material.dart';
import 'package:ridesewa/const/emergency_contact.dart';
import 'package:ridesewa/const/rate_customer_support.dart';
import 'package:ridesewa/const/report_issue.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportPassengerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help & Support', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          // FAQ Section with Expandable Lists
          ExpansionTile(
            leading: Icon(Icons.help_outline, color: Colors.blue),
            title: Text('Frequently Asked Questions', style: TextStyle(fontWeight: FontWeight.bold)),
            children: <Widget>[
              ListTile(
                title: Text('How do I book a ride?'),
                onTap: () {
                  _showFAQAnswer(context, 'To book a ride, open the app, enter your pickup and drop-off locations, and choose your ride option.');
                },
              ),
              ListTile(
                title: Text('What should I do if I can\'t find a ride?'),
                onTap: () {
                  _showFAQAnswer(context, 'If you can\'t find a ride, try refreshing your location or check for availability in nearby areas.');
                },
              ),
              ListTile(
                title: Text('How do I make a payment?'),
                onTap: () {
                  _showFAQAnswer(context, 'Payments are automatically processed after your ride ends. You can use a credit card, debit card, or other available payment methods.');
                },
              ),
              // More FAQ items for passengers
            ],
          ),

          // Contact Support Section with Multiple Options
          ListTile(
            leading: Icon(Icons.phone, color: Colors.blue),
            title: Text('Contact Support', style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              _showContactOptions(context);
            },
          ),

          // Troubleshooting Section
          ListTile(
            leading: Icon(Icons.settings, color: Colors.blue),
            title: Text('Troubleshooting', style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              _showTroubleshootingSteps(context);
            },
          ),

          // Report an Issue Section
          ListTile(
            leading: Icon(Icons.report_problem,color: Colors.blue),
            title: Text('Report an Issue', style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReportIssuePage()),
              );
            },
          ),

          // Ratings & Feedback Section
          ListTile(
            leading: Icon(Icons.star, color: Colors.blue),
            title: Text('Rate Your Ride Experience', style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RateSupportExperiencePage()),
                );
              },
          ),

          // Emergency Contacts Section
          ListTile(
            leading: Icon(Icons.warning, color: Colors.blue),
            title: Text('Emergency Contacts', style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EmergencyContactPage()),
                );
              },
          ),

          // Chat Support Button for Live Assistance
          ListTile(
            leading: Icon(Icons.chat, color: Colors.blue),
            title: Text('Chat with Support', style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              _openChat(context);
            },
          ),
        ],
      ),
    );
  }

  // Function to show the FAQ answer in a dialog
  void _showFAQAnswer(BuildContext context, String answer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('FAQ Answer', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(answer, style: TextStyle(fontSize: 16)),
          actions: <Widget>[
            TextButton(
              child: Text('Close', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Function to show contact options for support (phone, email, etc.)
  void _showContactOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Contact Support', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.phone, color: Colors.blue),
                title: Text('Call Support', style: TextStyle(fontSize: 16)),
                onTap: () {
                  _makePhoneCall('tel:+9816658815');
                },
              ),
              ListTile(
                leading: Icon(Icons.email, color: Colors.blue),
                title: Text('Email Support', style: TextStyle(fontSize: 16)),
                onTap: () {
                  _sendEmail('prashantthakuree94@gmail.com');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to initiate a phone call
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunch(phoneUri.toString())) {
      await launch(phoneUri.toString());
    } else {
      throw 'Could not place call to $phoneNumber';
    }
  }

  // Function to send an email
  Future<void> _sendEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunch(emailUri.toString())) {
      await launch(emailUri.toString());
    } else {
      throw 'Could not open email client';
    }
  }

  // Function to show troubleshooting steps
  void _showTroubleshootingSteps(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Troubleshooting Steps', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                ListTile(
                  title: Text('Step 1: Restart your app.', style: TextStyle(fontSize: 16)),
                ),
                ListTile(
                  title: Text('Step 2: Ensure your location settings are correct.', style: TextStyle(fontSize: 16)),
                ),
                ListTile(
                  title: Text('Step 3: Clear the app cache if the issue persists.', style: TextStyle(fontSize: 16)),
                ),
                // Add more steps here
              ],
            ),
          ),
        );
      },
    );
  }

  // Function to open live chat or chatbot
  void _openChat(BuildContext context) {
    // Open chat screen or connect with a chatbot for real-time support
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LiveChatScreen()),
    );
  }
}

class LiveChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Live Chat Support')),
      body: Center(
        child: Text('This is a live chat interface where passengers can talk to support agents.'),
      ),
    );
  }
}
