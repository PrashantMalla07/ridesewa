import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:ridesewa/Driver/accept_ride.dart';
import 'package:ridesewa/provider/driverprovider.dart';


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
              'id': request['id'],
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

  Future<void> _acceptRide(int rideId, LatLng pickupLocation, LatLng dropoffLocation) async {
  final driverProvider = Provider.of<DriverProvider>(context, listen: false);
  final driverUid = driverProvider.driver?.uid; // Use 'uid' instead of 'id'
  
  if (driverUid != null) {
    final url = 'http://localhost:3000/api/ride-requests/accept/$rideId';

    try {
      final response = await http.post(
  Uri.parse(url),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'rideId': rideId.toString(),
    'driver_uid': driverUid, // Ensure this is the correct field
    'pickup_location': jsonEncode({
      'latitude': pickupLocation.latitude,
      'longitude': pickupLocation.longitude,
    }),
    'dropoff_location': jsonEncode({
      'latitude': dropoffLocation.latitude,
      'longitude': dropoffLocation.longitude,
    }),
  }),
);


      if (response.statusCode == 200) {
        setState(() {
          rideRequests.removeWhere((request) => request['id'] == rideId);
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RideAcceptedPage(
              driverLocation: _driverLocation!,
              userLocation: pickupLocation,
              destination: dropoffLocation,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to accept ride: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Driver UID is not available.')),
    );
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
      appBar: AppBar(
        title: Text('Ride Requests'),
      ),
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
                                          final int? rideId = request['id'];
                                          final LatLng? pickupLocation = request['pickup'];
                                          final LatLng? dropoffLocation = request['dropoff'];

                                          if (rideId != null && pickupLocation != null && dropoffLocation != null) {
                                            _acceptRide(rideId, pickupLocation, dropoffLocation);
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Invalid ride request data.')),
                                            );
                                          }
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
