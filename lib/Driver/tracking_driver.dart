import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class DriverLocationTrackingPage extends StatefulWidget {
  final String driverId;
  final LatLng userLocation;
  final LatLng destination;

  DriverLocationTrackingPage({
    required this.driverId,
    required this.userLocation,
    required this.destination,
  });

  @override
  _DriverLocationTrackingPageState createState() =>
      _DriverLocationTrackingPageState();
}

class _DriverLocationTrackingPageState
    extends State<DriverLocationTrackingPage> {
  late LatLng _currentDriverLocation;
  Timer? _pollingTimer;
  bool _rideStarted = false;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _currentDriverLocation = widget.userLocation; // Initialize with user location
    _startPollingDriverLocation();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  // Poll driver location from the server
  void _startPollingDriverLocation() {
    _pollingTimer = Timer.periodic(Duration(seconds: 5), (_) async {
      try {
        final response = await http.get(
          Uri.parse("http://localhost:3000/api/driver-location/${widget.driverId}"),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            _currentDriverLocation =
                LatLng(data["latitude"], data["longitude"]);
            _rideStarted = data["rideStarted"];
          });
        } else {
          _setError("Failed to fetch driver location");
        }
      } catch (e) {
        _setError("Error: $e");
      }
    });
  }

  void _setError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  Future<void> _updateDriverLocation(LatLng newLocation) async {
    try {
      final response = await http.post(
        Uri.parse("http://localhost:3000/api/driver-location"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "driverId": widget.driverId,
          "latitude": newLocation.latitude,
          "longitude": newLocation.longitude,
          "rideStarted": _rideStarted,
        }),
      );

      if (response.statusCode != 200) {
        _setError("Failed to update driver location");
      }
    } catch (e) {
      _setError("Error updating location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Driver Location Tracking")),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: widget.userLocation,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: widget.userLocation,
                    width: 50,
                    height: 50,
                    child:  Icon(Icons.person_pin_circle,
                        color: Colors.red, size: 40),
                  ),
                  Marker(
                    point: _currentDriverLocation,
                    width: 50,
                    height: 50,
                    child:  Icon(Icons.local_taxi,
                        color: Colors.green, size: 40),
                  ),
                  Marker(
                    point: widget.destination,
                    width: 50,
                    height: 50,
                    child:  Icon(Icons.location_on,
                        color: Colors.blue, size: 40),
                  ),
                ],
              ),
            ],
          ),
          if (_errorMessage.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(8.0),
                color: Colors.red.withOpacity(0.8),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Driver Location: ${_currentDriverLocation.latitude.toStringAsFixed(5)}, ${_currentDriverLocation.longitude.toStringAsFixed(5)}",
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _updateDriverLocation(LatLng(
                        _currentDriverLocation.latitude + 0.001,
                        _currentDriverLocation.longitude + 0.001,
                      ));
                    },
                    child: Text("Simulate Driver Movement"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


