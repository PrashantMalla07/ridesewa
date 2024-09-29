import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:ridesewa/view/profile/drawer.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  LatLng _currentLocation = LatLng(28.2096, 83.9856); // Default location (Pokhara)
  LatLng? _destinationLocation; // Variable to store destination location
  String _destinationName = ''; // Variable to store destination name
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  double _currentZoom = 17.0; // Increased zoom level for better detail
  List<dynamic> _suggestions = []; // List to hold location suggestions
  List<LatLng> _mainRoutePoints = []; // Points for the main route
  List<List<LatLng>> _alternativeRoutePoints = []; // Points for alternative routes

  String _selectedRide = ''; // Variable to store selected ride type

  // Method to get current location using geolocator
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

  // Method to search for places and update suggestions
  Future<void> _searchPlace(String query) async {
    if (query.isEmpty) return; // Return early if the query is empty
    try {
      String simplifiedQuery = query.split(',').first; // Use only the first part of the input
      final response = await http.get(Uri.parse('https://nominatim.openstreetmap.org/search?q=$simplifiedQuery,Nepal&format=json&addressdetails=1&limit=5'));
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        setState(() {
          _suggestions = jsonResponse; // Store the entire response for later use
        });
      } else {
        print('Error fetching suggestions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
    }
  }

  // Method to update map with selected location and draw route
  void _updateMap(String place) async {
    try {
      String simplifiedPlace = place.split(',')[0]; // Use only the first part of the address
      final response = await http.get(Uri.parse('https://nominatim.openstreetmap.org/search?q=$simplifiedPlace,Nepal&format=json&addressdetails=1&limit=1'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse.isNotEmpty) {
          final location = jsonResponse[0];
          setState(() {
            _destinationLocation = LatLng(double.parse(location['lat']), double.parse(location['lon']));
            _destinationName = location['display_name']; // Store destination name
            _mapController.move(_destinationLocation!, _currentZoom);
            _suggestions.clear(); // Clear suggestions after selection
            _searchController.clear(); // Clear the search field
            _drawRoute(); // Draw routes to the destination
          });
        } else {
          print('No location found for: $place');
        }
      } else {
        print('Error fetching location: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating map: $e');
    }
  }

  // Method to draw the main and alternative routes from current location to destination
  Future<void> _drawRoute() async {
    if (_destinationLocation != null) {
      final url = 'https://router.project-osrm.org/route/v1/driving/'
          '${_currentLocation.longitude},${_currentLocation.latitude};'
          '${_destinationLocation!.longitude},${_destinationLocation!.latitude}'
          '?geometries=geojson&alternatives=2';

      try {
        final response = await http.get(Uri.parse(url)).timeout(Duration(seconds: 15));
        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          // Process the routes here...
        } else {
          print('Error fetching routes: ${response.statusCode}');
          if (response.statusCode == 500) {
            print('Internal Server Error: Retrying...');
          }
          print('Response body: ${response.body}'); // Log the response body for debugging
        }
      } catch (e) {
        print('Error drawing routes: $e');
        if (i == retries - 1) {
          print('Max retries reached, unable to fetch routes.');
        }
      }
      await Future.delayed(Duration(seconds: 2 * (i + 1))); // Exponential backoff
    }
  } else {
    print('Destination location is null');
  }
}



List<LatLng> _extractLatLngPoints(dynamic route) {
  return route['geometry']['coordinates']
      .map<LatLng>((point) => LatLng(point[1], point[0]))
      .toList();
}



  // Method to handle search button press
  void _onSearch() {
    String query = _searchController.text;
    if (query.isNotEmpty) {
      _updateMap(query); // Search for the place typed in the search bar
    }
  }

  // Method to calculate distance between two points
  String calculateDistance(LatLng start, LatLng end) {
    final distanceInMeters = Geolocator.distanceBetween(start.latitude, start.longitude, end.latitude, end.longitude);
    return (distanceInMeters / 1000).toStringAsFixed(2); // Return distance in kilometers
  }

  // Handle ride selection (Bike or Car)
  void _selectRide(String ride) {
    setState(() {
      _selectedRide = ride;
    });
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Get the user's location on startup
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Text('Home', style: TextStyle(color: Colors.black)),
      ),
      drawer: AppDrawer(),
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
                      Icons.place,
                      color: Colors.red,
                      size: 40.0,
                    ),
                  ),
                  if (_destinationLocation != null)
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: _destinationLocation!,
                      child: Icon(
                        Icons.place,
                        color: Colors.blue,
                        size: 40.0,
                      ),
                    ),
                ],
              ),
              PolylineLayer(
            polylines: [
              if (_mainRoutePoints.isNotEmpty)
                Polyline(
                  points: _mainRoutePoints,
                  strokeWidth: 4.0,
                  color: Colors.blue, // Main route color
                ),
              ..._alternativeRoutePoints
                  .where((points) => points.isNotEmpty) // Ensure alternative points are not empty
                  .map((points) => Polyline(
                        points: points,
                        strokeWidth: 3.0,
                        color: Colors.green.withOpacity(0.5), // Alternative route color
                      )),
            ],
          ),

            ],
          ),
          Positioned(
            bottom: 20.0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05), // 5% padding on left and right
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: _searchPlace, // Fetch suggestions as user types
                              decoration: InputDecoration(
                                labelText: 'Enter destination',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.search),
                            onPressed: _onSearch, // Trigger search when search button is pressed
                          ),
                        ],
                      ),
                    ),
                    if (_suggestions.isNotEmpty)
                      Container(
                        height: 150.0, // Fixed height for suggestion list
                        child: ListView.builder(
                          itemCount: _suggestions.length,
                          itemBuilder: (context, index) {
                            final suggestion = _suggestions[index]['display_name'];
                            return ListTile(
                              title: Text(suggestion),
                              onTap: () {
                                _updateMap(suggestion); // Update map with selected suggestion
                              },
                            );
                          },
                        ),
                      ),
                    if (_destinationLocation != null)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('From: Your Location'),
                                Text('To: $_destinationName'),
                                Text('Distance: ${calculateDistance(_currentLocation, _destinationLocation!)} km'),
                                SizedBox(height: 10),
                                Text('Select a Ride:'),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        _selectRide('Bike');
                                      },
                                      child: Stack(
                                        children: [
                                          Image.asset(
                                            'assets/bike.png',
                                            width: MediaQuery.of(context).size.width * 0.15,
                                            height: MediaQuery.of(context).size.width * 0.15,
                                          ),
                                          if (_selectedRide == 'Bike')
                                            Positioned(
                                              right: 0,
                                              bottom: 0,
                                              child: Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                                size: 24.0,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _selectRide('Car');
                                      },
                                      child: Stack(
                                        children: [
                                          Image.asset(
                                            'assets/car.png',
                                            width: MediaQuery.of(context).size.width * 0.15,
                                            height: MediaQuery.of(context).size.width * 0.15,
                                          ),
                                          if (_selectedRide == 'Car')
                                            Positioned(
                                              right: 0,
                                              bottom: 0,
                                              child: Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                                size: 24.0,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Center(
                                  child: ElevatedButton(
                                    onPressed: _selectedRide.isEmpty
                                        ? null // Disable button if no ride is selected
                                        : () {
                                            print('Ride started from ${_currentLocation.toString()} to ${_destinationLocation.toString()} with $_selectedRide');
                                             Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => RideRequestScreen()),
                                          );
                                          },
                                    child: Text('Find a Driver'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
