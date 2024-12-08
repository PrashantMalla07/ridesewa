import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:ridesewa/Driver/accept_ride.dart';

class RideRequestsPage extends StatefulWidget {
  @override
  _RideRequestsPageState createState() => _RideRequestsPageState();
}

class _RideRequestsPageState extends State<RideRequestsPage> {
  List<Map<String, dynamic>> rideRequests = [];
  LatLng? _driverLocation;
  bool _isLoading = false;
  bool _hasError = false;

  Future<void> _getRideRequests() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final userId = 6; // Replace this with the logged-in driver's ID.
    final url = 'http://localhost:3000/api/ride-requests/$userId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;

        setState(() {
          rideRequests = data.map((request) {
            return {
              'user': 'User ${request['user_id']}',
              'pickup': LatLng(
                request['pickup_location']['latitude'],
                request['pickup_location']['longitude'],
              ),
              'dropoff': LatLng(
                request['dropoff_location']['latitude'],
                request['dropoff_location']['longitude'],
              ),
            };
          }).toList();
        });
      } else {
        setState(() {
          _hasError = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load ride requests: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() {
        _hasError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location services are disabled. Please enable them.')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location permissions are permanently denied.')),
          );
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _driverLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getRideRequests();
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
      
      appBar: AppBar(//automaticallyImplyLeading: false,
      title: Text('Ride Requests')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(child: Text('Failed to load ride requests'))
              : rideRequests.isEmpty
                  ? Center(child: Text('No ride requests available'))
                  : ListView.builder(
                      itemCount: rideRequests.length,
                      itemBuilder: (context, index) {
                        final request = rideRequests[index];
                        return Card(
                          elevation: 2,
                          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: ListTile(
                            leading: CircleAvatar(child: Icon(Icons.person)),
                            title: Text(request['user'] ?? 'Unknown User'),
                            subtitle: Text(
                              'Pickup: ${request['pickup'].latitude}, ${request['pickup'].longitude}\n'
                              'Dropoff: ${request['dropoff'].latitude}, ${request['dropoff'].longitude}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton(
                                  onPressed: _driverLocation != null
                                      ? () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => RideAcceptedPage(
                                                driverLocation: _driverLocation!,
                                                userLocation: request['pickup'],
                                                destination: request['dropoff'],
                                              ),
                                            ),
                                          );
                                        }
                                      : null,
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
