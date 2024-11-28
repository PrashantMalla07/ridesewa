import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // Import the geolocator package
import 'package:latlong2/latlong.dart';
import 'package:ridesewa/Driver/accept_ride.dart';

class RideRequestsPage extends StatefulWidget {
  @override
  _RideRequestsPageState createState() => _RideRequestsPageState();
}

class _RideRequestsPageState extends State<RideRequestsPage> {
  List<Map<String, String>> rideRequests = [
    {
      'user': 'John Doe',
      'pickup': 'Pokhara Lakeside',
      'dropoff': 'Bagar, Pokhara',
    },
    {
      'user': 'Jane Smith',
      'pickup': 'Kathmandu Durbar Square',
      'dropoff': 'Bhaktapur',
    },
  ];

  LatLng? _driverLocation;
  bool _isLoading = false;

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await Geolocator.requestPermission() != LocationPermission.denied;
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _driverLocation = LatLng(position.latitude, position.longitude);
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void cancelRide(int index) {
    setState(() {
      rideRequests.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ride Requests')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: rideRequests.length,
              itemBuilder: (context, index) {
                final request = rideRequests[index];
                return Card(
                  elevation: 2,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: CircleAvatar(child: Icon(Icons.person)),
                    title: Text(request['user']!),
                    subtitle: Text(
                      'Pickup: ${request['pickup']}\nDropoff: ${request['dropoff']}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (_driverLocation != null) {
                              // Navigate to DriverAtUserLocationPage with the required data
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RideAcceptedPage(
                                    driverLocation: _driverLocation!,
                                    userLocation: LatLng(28.23223, 83.99080), // Replace with actual user pickup location
                                    destination: LatLng(28.20662, 83.99344), // Replace with actual destination (dropoff location)
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Unable to get driver location!')),
                              );
                            }
                          },
                          child: Text('Accept'),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => cancelRide(index),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: Text('Cancel'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
