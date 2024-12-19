import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:ridesewa/BaseUrl.dart';
import 'package:ridesewa/Driver/reach_location.dart';
import 'package:ridesewa/provider/driverprovider.dart';

class RideAcceptedPage extends StatefulWidget {
  final LatLng driverLocation;
  final LatLng userLocation;
  final LatLng destination;

  RideAcceptedPage({
    required LatLng driverLocation, // Accept the parameter
    required this.userLocation,
    required this.destination,
  }) : driverLocation = LatLng(28.221965, 83.997540); 

  @override
  _RideAcceptedPageState createState() => _RideAcceptedPageState();
}

class _RideAcceptedPageState extends State<RideAcceptedPage>
    with SingleTickerProviderStateMixin {
  final Dio _dio = Dio();
  final MapController _mapController = MapController();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  double _currentZoom = 15.0;
  List<LatLng> routePoints = [];
  LatLng? _driverLocation;
  String _eta = '';
  String _distance = '';
  String _errorMessage = '';
  double? _averageRating;
  Map<String, dynamic>? _driverData;

  bool _isRouteReady = false;
  bool _isLoading = true;

  late AnimationController _animationController;
  Animation<LatLng>? _locationAnimation;
  Timer? _animationTimer;

  @override
  void initState() {
    super.initState();
    _driverLocation = widget.driverLocation;

    _initializeAnimationController();
    _simulateDriverMovement();
    _fetchDriverDetails();
    _fetchDriverRating();
    _fetchRoute();
  }

  void _initializeAnimationController() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        setState(() {
          _driverLocation = _locationAnimation?.value;
        });
      });
  }

  Future<void> _fetchDriverDetails() async {
    try {
      final driverProvider = Provider.of<DriverProvider>(context, listen: false);
      final driverUid = driverProvider.driver?.uid;

      if (driverUid == null) {
        throw Exception("Driver UID is not available.");
      }

      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/driver/profile/$driverUid'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _driverData = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch driver details: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error fetching driver details: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchDriverRating() async {
    try {
      final driverProvider = Provider.of<DriverProvider>(context, listen: false);
      final driverUid = driverProvider.driver?.uid;

      if (driverUid == null) {
        throw Exception("Driver UID is not available.");
      }

      final token = await _storage.read(key: 'auth_token');
      final response = await _dio.get(
        '${BaseUrl.baseUrl}/api/driver_ratings/driver/$driverUid',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _averageRating = double.tryParse(response.data['average_rating'].toString()) ?? 5.0;
        });
      } else {
        throw Exception('Failed to fetch average rating: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error fetching rating: $e";
      });
    }
  }

  Future<void> _fetchRoute() async {
    final osrmUrl =
        'http://router.project-osrm.org/route/v1/driving/${_driverLocation!.longitude},${_driverLocation!.latitude};${widget.userLocation.longitude},${widget.userLocation.latitude}?overview=full&geometries=polyline';

    try {
      final response = await http.get(Uri.parse(osrmUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final polyline = data['routes'][0]['geometry'];
        final distanceInMeters = data['routes'][0]['distance'];
        final durationInSeconds = data['routes'][0]['duration'];

        setState(() {
          _distance = (distanceInMeters / 1000).toStringAsFixed(2);
          _eta =
              '${(durationInSeconds / 60).floor()} min ${(durationInSeconds % 60).floor()} sec';
          routePoints = _decodePolyline(polyline);
          _isRouteReady = true;
        });

        if (_isRouteReady) {
          _startRide();
        }
      } else {
        throw Exception('Failed to fetch route: ${response.body}');
      }
    } catch (e) {
      print("Error fetching route: $e");
    }
  }

  void _startRide() {
    if (!_isRouteReady) {
      print('Route is not ready.');
      return;
    }

    int currentIndex = 0;

    _animationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (currentIndex < routePoints.length - 1) {
        final startPoint = routePoints[currentIndex];
        final endPoint = routePoints[currentIndex + 1];

        _locationAnimation = LatLngTween(
          begin: startPoint,
          end: endPoint,
        ).animate(_animationController);

        _animationController.reset();
        _animationController.forward();

        currentIndex++;
      } else {
        timer.cancel();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DriverAtUserLocationPage(
              driverLocation: _driverLocation!,
              userLocation: widget.userLocation,
              destination: widget.destination,
            ),
          ),
        );
      }
    });
  }

  void _simulateDriverMovement() {
    Timer.periodic(const Duration(seconds: 3), (_) {
      setState(() {
        _driverLocation = LatLng(
          _driverLocation!.latitude + 0.0001,
          _driverLocation!.longitude + 0.0001,
        );
      });
    });
  }

  List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    int index = 0, lat = 0, lng = 0;

    while (index < encoded.length) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _animationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ride Accepted')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ride Accepted')),
        body: Center(child: Text(_errorMessage)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ride Accepted')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _driverLocation!,
              initialZoom: _currentZoom,
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
                    point: _driverLocation!,
                    child: const Icon(Icons.local_taxi, color: Colors.green, size: 40),
                  ),
                  Marker(
                    width: 50.0,
                    height: 50.0,
                    point: widget.userLocation,
                    child: const Icon(Icons.person_pin_circle, color: Colors.red, size: 40),
                  ),
                ],
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routePoints,
                    strokeWidth: 4.0,
                    color: Colors.blue,
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildDriverInfo(),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverInfo() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Driver Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(_driverData?['imageUrl'] ?? 'https://via.placeholder.com/150'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  if (_driverData != null) ...[
                    Text(
                      _driverData!['first_name'] + ' ' + _driverData!['last_name'] ?? 'Driver Name',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 5),
                        Text('Rating: ${_averageRating?.toStringAsFixed(1) ?? 'N/A'}'),
                      ],
                    ),
                  ],
                  SizedBox(height: 10),
                  Text(
                    'Distance: $_distance km',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'ETA: $_eta',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.call, color: Colors.green, size: 30),
                onPressed: () => print('Calling user...'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
