import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:ridesewa/BaseUrl.dart';
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

  Future<String> _getPlaceName(LatLng location) async {
    final url = 'https://nominatim.openstreetmap.org/reverse?format=json&lat=${location.latitude}&lon=${location.longitude}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['display_name'] ?? 'Unknown Location';
      } else {
        return 'Error fetching location';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<void> _getRideRequests() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final url = '${BaseUrl.baseUrl}/api/ride-requests/getRide';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final rideRequestsList = await Future.wait(data.map((request) async {
          final userResponse = await http.get(
            Uri.parse('${BaseUrl.baseUrl}/api/users/${request['user_id']}'),
          );

          String userName = 'Unknown User';
          String userImage = '';
          String userAverageRating = '0';

          if (userResponse.statusCode == 200) {
            final userData = jsonDecode(userResponse.body);
            userName = '${userData['first_name']} ${userData['last_name']}';
            userImage = userData['image'] ?? '';
            userAverageRating = userData['average_rating']?.toString() ?? '0';
          }

          final pickupLocation = LatLng(
            request['pickup_location']['latitude'],
            request['pickup_location']['longitude'],
          );
          final dropoffLocation = LatLng(
            request['dropoff_location']['latitude'],
            request['dropoff_location']['longitude'],
          );

          final pickupName = await _getPlaceName(pickupLocation);
          final dropoffName = await _getPlaceName(dropoffLocation);

          return {
            'id': request['id'],
            'user_id': request['user_id'],
            'user_name': userName,
            'user_image': userImage,
            'user_average_rating': userAverageRating,
            'pickup': pickupLocation,
            'dropoff': dropoffLocation,
            'pickup_location': pickupName,
            'dropoff_location': dropoffName,
          };
        }).toList());

        setState(() {
          rideRequests = rideRequestsList;
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
    final driverUid = driverProvider.driver?.uid;
    if (driverUid != null) {
      final url = '${BaseUrl.baseUrl}/api/ride-requests/accept/$rideId';

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'rideId': rideId.toString(),
            'driver_uid': driverUid,
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

  void cancelRide(int index) {
    setState(() {
      rideRequests.removeAt(index);
    });
  }

  @override
  void initState() {
    super.initState();
    _getRideRequests();
    _getCurrentLocation();
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
                            leading: request['user_image'].isNotEmpty
                                ? CircleAvatar(backgroundImage: NetworkImage(request['user_image']))
                                : CircleAvatar(child: Icon(Icons.person)),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    request['user_name'] ?? 'Unknown User',
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.star, color: Colors.amber, size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      request['user_average_rating'],
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pickup: ${request['pickup_location']}',
                                ),
                                Text(
                                  'Dropoff: ${request['dropoff_location']}',
                                ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  child: IconButton(
                                    icon: Icon(Icons.check_circle, color: Colors.green),
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
                                  ),
                                ),
                                SizedBox(height: 10),
                                Expanded(
                                  child: IconButton(
                                    icon: Icon(Icons.cancel, color: Colors.red),
                                    onPressed: () => cancelRide(index),
                                  ),
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
