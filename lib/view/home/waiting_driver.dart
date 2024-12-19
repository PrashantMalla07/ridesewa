import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:ridesewa/BaseUrl.dart';
import 'package:ridesewa/Driver/accept_ride.dart';
import 'package:ridesewa/view/home/HomeView.dart';

class WaitingForDriverScreen extends StatefulWidget {
  final int rideRequestId;

  WaitingForDriverScreen({required this.rideRequestId});

  @override
  _WaitingForDriverScreenState createState() => _WaitingForDriverScreenState();
}

class _WaitingForDriverScreenState extends State<WaitingForDriverScreen> {
  Timer? _timer;
  bool _rideAccepted = false;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _checkRideStatus();
    });
  }

  Future<void> _checkRideStatus() async {
  final rideRequestId = widget.rideRequestId;
  final url = '${BaseUrl.baseUrl}/api/ride-status/$rideRequestId';

  try {
    print('Checking ride status...');
    final response = await http.get(Uri.parse(url));
    print('Response status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Response data: $data');
      if (data['status'] == 'accepted') {
        final driverLocation = data['driver_location'];
        final pickupLocation = data['pickup_location'];
        final dropoffLocation = data['dropoff_location'];

        if (driverLocation != null && pickupLocation != null && dropoffLocation != null) {
          setState(() {
            _rideAccepted = true;
          });
          print('Ride accepted, navigating to RideAcceptedPage...');
          _navigateToRideAcceptedPage(
            LatLng(driverLocation['latitude'], driverLocation['longitude']),
            LatLng(pickupLocation['latitude'], pickupLocation['longitude']),
            LatLng(dropoffLocation['latitude'], dropoffLocation['longitude']),
          );
        } else {
          print('Error: One of the locations is null.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: Missing location data.')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to check ride status: ${response.statusCode}')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}

  void _navigateToRideAcceptedPage(LatLng driverLocation, LatLng userLocation, LatLng destination) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => RideAcceptedPage(
          driverLocation: driverLocation,
          userLocation: userLocation,
          destination: destination,
        ),
      ),
      (route) => false, // Remove all previous routes
    );
  }

  void _cancelRide(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomeView()), // HomeView is your home page widget
      (route) => false, // This removes all previous routes from the stack
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(30.0),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.3),
                    blurRadius: 20.0,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                strokeWidth: 6,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Waiting for driver to accept ride...',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: Text(
                'Please wait while we find the best driver for you. This might take a few moments.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 50.0),
              child: ElevatedButton(
                onPressed: () => _cancelRide(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  shadowColor: Colors.black.withOpacity(0.3),
                  elevation: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cancel_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Text('Cancel Ride', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
