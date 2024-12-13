import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:ridesewa/provider/driverprovider.dart';

class RideHistoryDrawer extends StatefulWidget {
  @override
  _RideHistoryDrawerState createState() => _RideHistoryDrawerState();
}

class _RideHistoryDrawerState extends State<RideHistoryDrawer> {
  List<Map<String, dynamic>> rideHistory = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchRideHistory();
  }

Future<void> _fetchRideHistory() async {
  final driverProvider = Provider.of<DriverProvider>(context, listen: false);
  final driverUid = driverProvider.driver?.uid;

  if (driverUid == null) {
    setState(() {
      _hasError = true;
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Driver UID is not available')),
    );
    return;
  }

  final url = 'http://localhost:3000/api/rides/$driverUid';

  try {
    print('Sending request to: $url');  // Log the URL being called

    final response = await http.get(Uri.parse(url));
    print('Response status: ${response.statusCode}');  // Log the response status

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      print('Response body: $data');  // Log the response data

      setState(() {
        rideHistory = data.map((ride) {
          return {
            'id': ride['id'],
            'user_id': ride['user_id'],
            'pickup': LatLng(
              ride['pickup_location']['latitude'],
              ride['pickup_location']['longitude'],
            ),
            'dropoff': LatLng(
              ride['dropoff_location']['latitude'],
              ride['dropoff_location']['longitude'],
            ),
            'status': ride['status'],
            'created_at': ride['created_at'],
            'completed_at': ride['completed_at'],
          };
        }).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      print('Failed to load ride history, status code: ${response.statusCode}');  // Log error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load ride history: ${response.statusCode}')),
      );
    }
  } catch (e) {
    // Log the error to the terminal
    print('Error fetching ride history: $e');  // This will log any errors in the catch block

    setState(() {
      _hasError = true;
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ride History'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(child: Text('Failed to load ride history'))
              : ListView.builder(
                  itemCount: rideHistory.length,
                  itemBuilder: (context, index) {
                    final ride = rideHistory[index];
                    return ListTile(
                      title: Text('Ride ID: ${ride['id']}'),
                      subtitle: Text('Status: ${ride['status']}'),
                      trailing: Text('Completed At: ${ride['completed_at'] ?? 'N/A'}'),
                      onTap: () {
                        // Navigate to ride details if needed
                      },
                    );
                  },
                ),
    );
  }
}
