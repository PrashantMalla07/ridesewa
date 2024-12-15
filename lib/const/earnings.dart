import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:ridesewa/provider/driverprovider.dart';

class DriverEarningsPage extends StatefulWidget {
  @override
  _DriverEarningsPageState createState() => _DriverEarningsPageState();
}

class _DriverEarningsPageState extends State<DriverEarningsPage> {
  List<dynamic> _earnings = [];

  @override
  void initState() {
    super.initState();
    fetchEarnings();
  }

  Future<void> fetchEarnings() async {
    try {
      final driverProvider = Provider.of<DriverProvider>(context, listen: false);
      final String? driveruid = driverProvider.driver?.uid?.toString();

      final response = await http.get(Uri.parse('http://localhost:3000/api/earnings/driver/$driveruid'));

      if (response.statusCode == 200) {
        setState(() {
          _earnings = jsonDecode(response.body);
        });
      } else {
        throw Exception('Failed to load earnings with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Earnings'),
      ),
      body: _earnings.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _earnings.length,
              itemBuilder: (context, index) {
                final payment = _earnings[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  elevation: 4.0,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16.0),
                    title: Text('Ride ID: ${payment['ride_id']}',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4.0),
                        Text('User ID: ${payment['user_id']}'),
                        Text('Amount: ${payment['amount']}'),
                        Text('Payment Method: ${payment['payment_method']}'),
                        Text('Status: ${payment['status']}'),
                        Text('Date: ${payment['payment_date']}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
