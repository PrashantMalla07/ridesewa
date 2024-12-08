import 'package:flutter/material.dart';
import 'package:ridesewa/const/help_support.dart';

class DriverResourcesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Resources'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HelpSupportPage()),
            );
          },
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.security, color: Colors.blue),
            title: Text('Driver Safety Guidelines'),
            onTap: () {
              _showSafetyGuidelines(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.book, color: Colors.blue),
            title: Text('Driver Handbook'),
            onTap: () {
              _showDriverHandbook(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.monetization_on, color: Colors.blue),
            title: Text('Earnings & Payments Guide'),
            onTap: () {
              _showEarningsGuide(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.directions_car, color: Colors.blue),
            title: Text('Vehicle Requirements & Maintenance'),
            onTap: () {
              _showVehicleRequirements(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.school, color: Colors.blue),
            title: Text('Driver Training & Tutorials'),
            onTap: () {
              _showTrainingTutorials(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.favorite, color: Colors.blue),
            title: Text('Health & Wellness Resources'),
            onTap: () {
              _showHealthResources(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.gavel, color: Colors.blue),
            title: Text('Legal & Insurance Information'),
            onTap: () {
              _showLegalInformation(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.help, color: Colors.blue),
            title: Text('Driver Support'),
            onTap: () {
              _showSupport(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.card_giftcard, color: Colors.blue),
            title: Text('Rewards & Incentives'),
            onTap: () {
              _showRewards(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.group, color: Colors.blue),
            title: Text('Community Engagement & Events'),
            onTap: () {
              _showCommunityEvents(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.attach_money, color: Colors.blue),
            title: Text('Tax & Financial Resources'),
            onTap: () {
              _showFinancialResources(context);
            },
          ),
        ],
      ),
    );
  }

  void _showSafetyGuidelines(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Driver Safety Guidelines'),
          content: Text('Information on driver safety, including defensive driving, accident protocols, etc.'),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showDriverHandbook(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Driver Handbook'),
          content: Text('A comprehensive guide for drivers, including policies, safety, and conduct.'),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showEarningsGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Earnings & Payments Guide'),
          content: Text('Learn how earnings are calculated, the payout process, and tips on increasing your income.'),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showVehicleRequirements(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Vehicle Requirements & Maintenance'),
          content: Text('Ensure your vehicle meets the company standards, and learn how to maintain it properly.'),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showTrainingTutorials(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Driver Training & Tutorials'),
          content: Text('Access helpful tutorials for using the app, improving customer service, and handling situations.'),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showHealthResources(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Health & Wellness Resources'),
          content: Text('Find tips on staying healthy while driving, such as stretching exercises and ways to combat fatigue.'),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showLegalInformation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Legal & Insurance Information'),
          content: Text('Learn about your rights and obligations, insurance details, and what to do in case of an accident.'),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Driver Support'),
          content: Text('Here you can find support resources, including FAQs, direct contact options, and troubleshooting guides.'),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showRewards(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rewards & Incentives'),
          content: Text('Discover various rewards programs, including bonuses for high ratings, completing trips, etc.'),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showCommunityEvents(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Community Engagement & Events'),
          content: Text('Learn about meetups, webinars, and events where you can connect with fellow drivers and share tips.'),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showFinancialResources(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tax & Financial Resources'),
          content: Text('Get advice on tax deductions, budgeting for drivers, and tools to manage your finances.'),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}