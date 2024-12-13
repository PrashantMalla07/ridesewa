import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:ridesewa/Driver/driver_drawer.dart';
import 'package:ridesewa/Driver/ride_request.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverHomeView extends StatefulWidget {
  @override
  _DriverHomeViewState createState() => _DriverHomeViewState();
}

class _DriverHomeViewState extends State<DriverHomeView> {
  LatLng _currentLocation = LatLng(28.2096, 83.9856);
  final MapController _mapController = MapController();
  double _currentZoom = 15.0;
  bool isOnline = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _mapController.move(_currentLocation, _currentZoom);
        });
      }
    } catch (e) {
      print('Error getting current location: $e');
    }
  }
   // Define the logout function
  // ignore: unused_element
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken'); // Remove the authentication token or any other saved data
    // Redirect to the login page or any other page
    Navigator.pushReplacementNamed(context, '/login');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Driver Dashboard"),
      ),
      drawer: DriverDrawer(
      //   onStatusToggle: (value) {
      //     setState(() {
      //       isOnline = value;
      //     });
      //   },
      //   onLogout: _logout, // Provide the logout function
      ), 
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation,
              initialZoom: _currentZoom,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: _currentLocation,
                    child: Icon(
                      Icons.local_taxi,
                      color: Colors.green,
                      size: 40.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Stay on the map (current page)
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => DriverHomeView()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: Colors.blueAccent,
                    elevation: 5,
                  ),
                  child: Text(
                    'Map',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the Ride Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RideRequestsPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: Colors.greenAccent,
                    elevation: 5,
                  ),
                  child: Text(
                    'Ride',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

