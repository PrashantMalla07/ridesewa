import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:ridesewa/const/ride_detail_from_triphistory.dart';
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

  final url = 'http://localhost:3000/api/rides/driver/$driverUid';

  try {
    print('Sending request to: $url'); // Log the URL being called

    final response = await http.get(Uri.parse(url));
    print('Response status: ${response.statusCode}'); // Log the response status

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      print('Response body: $data'); // Log the response data

      if (data is List) {
        setState(() {
          rideHistory = data.map((ride) {
            final pickupLocation = ride['pickup_location'] != null
                ? jsonDecode(ride['pickup_location'])
                : {'latitude': 0.0, 'longitude': 0.0};
            final dropoffLocation = ride['dropoff_location'] != null
                ? jsonDecode(ride['dropoff_location'])
                : {'latitude': 0.0, 'longitude': 0.0};

            return {
              'id': ride['id'] ?? 'N/A', // Default to 'N/A' if missing
              'user_id': ride['user_id'] ?? 'N/A', // Handle null cases
              'pickup': LatLng(
                pickupLocation['latitude'] ?? 0.0,
                pickupLocation['longitude'] ?? 0.0,
              ),
              'dropoff': LatLng(
                dropoffLocation['latitude'] ?? 0.0,
                dropoffLocation['longitude'] ?? 0.0,
              ),
              'status': ride['status'] ?? 'Unknown',
              'created_at': ride['created_at'] ?? 'Unknown',
              'completed_at': ride['completed_at'] ?? 'N/A',
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
        print('Error: Response body is not a list.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Response format is invalid')),
        );
      }
    } else {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      print('Failed to load ride history, status code: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load ride history: ${response.statusCode}')),
      );
    }
  } catch (e) {
    print('Error fetching ride history: $e'); // Log the error to the terminal

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
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RideDetailPage(ride: ride),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Icon or Avatar
              CircleAvatar(
                backgroundColor: Colors.blueAccent,
                radius: 28,
                child: Icon(Icons.directions_car, color: Colors.white, size: 28),
              ),
              SizedBox(width: 16),
              // Ride details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ride ID: ${ride['id']}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Pickup: ${ride['pickup'].latitude}, ${ride['pickup'].longitude}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    Text(
                      'Dropoff: ${ride['dropoff'].latitude}, ${ride['dropoff'].longitude}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              // Status and Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Status: ${ride['status']}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ride['status'] == 'Completed'
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Date: ${ride['completed_at']}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  },
),


    );
  }
}
