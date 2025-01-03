import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:ridesewa/Driver/payment.dart';
import 'package:ridesewa/Driver/rating.dart';
import 'package:ridesewa/provider/driverprovider.dart';

class DriverAtUserLocationPage extends StatefulWidget {
  final LatLng driverLocation;
  final LatLng userLocation;
  final LatLng destination;

  DriverAtUserLocationPage({
    required this.driverLocation,
    required this.userLocation,
    required this.destination,
  });

  @override
  _DriverAtUserLocationPageState createState() =>
      _DriverAtUserLocationPageState();
}

class _DriverAtUserLocationPageState extends State<DriverAtUserLocationPage> {
  List<LatLng> _routePoints = [];
  String _errorMessage = '';
  LatLng? _newDestination;
  double _distanceInKm = 0.0;
  double _estimatedPriceInNPR = 0.0;
  final double pricePerKmNPR = 30.0; // Price in NPR per kilometer
  late LatLng _currentDriverLocation;
  Timer? _movementTimer;
  int _routeIndex = 0;
  bool _rideStarted = false;

  @override
  void initState() {
    super.initState();
    _currentDriverLocation = widget.driverLocation; // Initialize driver's location
    _fetchRoute(); // Fetch initial route
  }

  @override
  void dispose() {
    _movementTimer?.cancel(); // Cancel timer when widget is disposed
    super.dispose();
  }

Future<void> _fetchRoute() async {
  final destination = _newDestination ?? widget.destination;
  final url =
      'http://router.project-osrm.org/route/v1/driving/${widget.userLocation.longitude},${widget.userLocation.latitude};${destination.longitude},${destination.latitude}?overview=full&geometries=polyline';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final route = data['routes'][0]['geometry'];

    final polyline = _decodePolyline(route);
    final distance = data['routes'][0]['legs'][0]['distance']; // Distance in meters

    setState(() {
      _routePoints = polyline;
      _errorMessage = '';
      _distanceInKm = distance / 1000.0; // Convert meters to kilometers
      _estimatedPriceInNPR = _distanceInKm * pricePerKmNPR; // Price in NPR
    });

    // Start ride automatically after fetching the route
    if (!_rideStarted) {
      _startRide();
    }
  } else {
    setState(() {
      _errorMessage = "Failed to fetch route: ${response.statusCode}";
    });
  }
}

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index) - 63;
        index++;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index) - 63;
        index++;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  void _startRide() {
  print("Starting the ride...");
  if (_routePoints.isEmpty) return;

  setState(() {
    _rideStarted = true;
  });

  _routeIndex = 0; // Start from the first route point
  const double averageSpeedMps = 11.1; // Average speed in meters per second (~40 km/h)

  _movementTimer = Timer.periodic(Duration(seconds: 1), (timer) {
    if (_routeIndex < _routePoints.length - 1) {
      setState(() {
        _currentDriverLocation = _routePoints[_routeIndex];
        _routeIndex++;

        // Update remaining distance and ETA
        _distanceInKm = _calculateRemainingDistance();
        _errorMessage =
            "ETA: ${(_distanceInKm / (averageSpeedMps * 3600 / 1000)).toStringAsFixed(1)} minutes remaining";
      });
    } else {
      timer.cancel();
      setState(() {
        _errorMessage = "Ride completed! Driver has arrived.";
        _distanceInKm = 0.0; // Reset distance
      });

      // Determine which page to show
      final driverProvider = Provider.of<DriverProvider>(context, listen: false);
      final String? driveruid = driverProvider.driver?.uid?.toString();

      if (driveruid != null) {
        _showRatingPage();
      } else {
        _showPaymentPage();
      }
    }
  });
}

void _showRatingPage() {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => RatingScreen()),
  );
}


  double _calculateRemainingDistance() {
    final distanceCalculator = Distance();
    final remainingDistance = distanceCalculator(
      _currentDriverLocation,
      _newDestination ?? widget.destination,
    );
    return remainingDistance / 1000.0; // Convert meters to kilometers
  }

  void _showPaymentPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PaymentPage(price: _estimatedPriceInNPR)),
    );
  }

  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      appBar: AppBar(
        title: Text("Driver at User Location"),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: widget.userLocation,
              initialZoom: 15.0,
              onTap: (tapPosition, point) {
                _onMapTapped(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 50.0,
                    height: 50.0,
                    point: _currentDriverLocation,
                    child: Icon(Icons.local_taxi, color: Colors.green, size: 40.0),
                  ),
                  Marker(
                    width: 50.0,
                    height: 50.0,
                    point: widget.userLocation,
                    child: Icon(Icons.person_pin_circle, color: Colors.red, size: 40.0),
                  ),
                  Marker(
                    width: 50.0,
                    height: 50.0,
                    point: _newDestination ?? widget.destination,
                    child: Icon(Icons.location_on, color: Colors.blue, size: 40.0),
                  ),
                ],
              ),
              PolylineLayer(
                polylines: [
                  Polyline(points: _routePoints, strokeWidth: 4.0, color: Colors.blue),
                ],
              ),
            ],
          ),
          if (!_rideStarted)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildStartRideContainer(),
            ),
          if (_rideStarted)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildRideProgressContainer(),
            ),
        ],
      ),
    );
  }

Widget _buildStartRideContainer() {
  return Container(
    padding: EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10.0, offset: Offset(0, -3))],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_errorMessage.isNotEmpty)
          Text(
            _errorMessage,
            style: TextStyle(
              color: _errorMessage.contains("ETA") ? Colors.black : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        Text(
          'Driver Location: (${_currentDriverLocation.latitude.toStringAsFixed(5)}, ${_currentDriverLocation.longitude.toStringAsFixed(5)})',
          style: TextStyle(fontSize: 14),
        ),
        Text(
          'Remaining Distance: ${_distanceInKm.toStringAsFixed(2)} km',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}

  Widget _buildRideProgressContainer() {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10.0, offset: Offset(0, -3))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _errorMessage,
            style: TextStyle(
              color: _errorMessage.contains("ETA") ? Colors.black : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Driver Location: (${_currentDriverLocation.latitude.toStringAsFixed(5)}, ${_currentDriverLocation.longitude.toStringAsFixed(5)})',
            style: TextStyle(fontSize: 14),
          ),
          Text(
            'Remaining Distance: ${_distanceInKm.toStringAsFixed(2)} km',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _onMapTapped(LatLng tappedLocation) {
    setState(() {
      _newDestination = tappedLocation;
      _routePoints.clear();
      _fetchRoute();
    });
  }
}
