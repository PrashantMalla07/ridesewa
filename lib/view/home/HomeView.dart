import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:ridesewa/view/home/waiting_driver.dart';
import 'package:ridesewa/view/profile/drawer.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  LatLng _currentLocation = LatLng(28.2096, 83.9856);
  LatLng? _destinationLocation;
  String _destinationName = '';
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  double _currentZoom = 17.0;
  List<dynamic> _suggestions = [];
  List<LatLng> _mainRoutePoints = [];
  List<List<LatLng>> _alternativeRoutePoints = [];
  String _selectedRide = 'Bike'; // Default to 'Bike'
  bool _rideStarted = false; // Track if the ride has started
  bool _isSearchBarVisible = true; // Flag to manage search bar visibility
  bool _isStartRideVisible = true; // Flag to manage start ride button visibility
  final double _radiusInMeters = 100;
  
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

  Future<void> _searchPlace(String query) async {
    if (query.isEmpty) return;
    try {
      String simplifiedQuery = query.split(',').first;
      final response = await http.get(Uri.parse('https://nominatim.openstreetmap.org/search?q=$simplifiedQuery,Nepal&format=json&addressdetails=1&limit=5'));
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        setState(() {
          _suggestions = jsonResponse;
        });
      } else {
        print('Error fetching suggestions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
    }
  }

  void _updateMap(String place) async {
    try {
      String simplifiedPlace = place.split(',')[0];
      final response = await http.get(Uri.parse('https://nominatim.openstreetmap.org/search?q=$simplifiedPlace,Nepal&format=json&addressdetails=1&limit=1'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse.isNotEmpty) {
          final location = jsonResponse[0];
          setState(() {
            _destinationLocation = LatLng(double.parse(location['lat']), double.parse(location['lon']));
            _destinationName = location['display_name'];
            _mapController.move(_destinationLocation!, _currentZoom);
            _suggestions.clear();
            _searchController.clear();
            _drawRoute();
            _isSearchBarVisible = false; // Hide search bar after successful search
            _isStartRideVisible = true; // Show start ride button
            _selectedRide = 'Bike'; // Automatically select bike ride
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
        }
      } catch (e) {
        print('Error drawing routes: $e');
      }
    } else {
      print('Destination location is null');
    }
  }

  void _startRide() {
    setState(() {
      _rideStarted = true; // Mark ride as started
      _isStartRideVisible = false; // Hide start ride button
    });
  }

  void _cancelRide() {
    setState(() {
      _rideStarted = false; // Reset the ride status
      _destinationLocation = null; // Clear the destination
      _destinationName = ''; // Clear the destination name
      _selectedRide = 'Bike'; // Reset the selected ride to 'Bike'
      _suggestions.clear(); // Clear any suggestions
      _searchController.clear(); // Clear the search field
      _isSearchBarVisible = true; // Show search bar again
      _isStartRideVisible = true; // Show start ride button again
    });
  }

  void _selectRide(String ride) {
    setState(() {
      _selectedRide = ride;
    });
  }
  
 void _onMapTap(LatLng tappedLocation) {
  if (_destinationLocation != null) {
    // Check if the tap is on the current destination
    final distanceToDestination = Geolocator.distanceBetween(
      tappedLocation.latitude,
      tappedLocation.longitude,
      _destinationLocation!.latitude,
      _destinationLocation!.longitude,
    );

    if (distanceToDestination < 10) { // 10 meters threshold for tapping accuracy
      // Undo the destination
      setState(() {
        _destinationLocation = null;
      });
      print("Destination removed.");
      return; // Exit early
    }
  }

  // Calculate the distance between the tapped location and the current location
  final distanceToCurrent = Geolocator.distanceBetween(
    _currentLocation.latitude,
    _currentLocation.longitude,
    tappedLocation.latitude,
    tappedLocation.longitude,
  );

  if (_destinationLocation == null) {
    // Set the destination location
    setState(() {
      _destinationLocation = tappedLocation;
      _mapController.move(tappedLocation, _currentZoom);
    });
    print("Destination set.");
  } else if (distanceToCurrent <= 100) {
    // Set the current location if within 100 meters
    setState(() {
      _currentLocation = tappedLocation;
      _mapController.move(tappedLocation, _currentZoom);
    });
    print("Pickup point set.");
  } else {
    // Optionally, provide feedback if tap is too far
    print("Tap is too far from the current location to be the pickup point.");
  }
}
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _selectedRide = 'Bike';
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
              onTap: (tapPosition, point) {
                _onMapTap(point);  // Call _onMapTap when the user taps on the map
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.example.app',
              ),
              CircleLayer(
            circles: [
              CircleMarker(
                point: _currentLocation,
                color: Colors.blue.withOpacity(0.1),
                borderStrokeWidth: 2,
                borderColor: Colors.blue,
                radius: _radiusInMeters,  // 100 meter radius
              ),
            ],
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
            ],
          ),Positioned(
      top: 20.0,
      right: 20.0,
      child: FloatingActionButton(
        onPressed: _getCurrentLocation,
        backgroundColor: Colors.white,
        child: Icon(Icons.my_location, color: Colors.black),
      ),
    ),
          if (_isSearchBarVisible)
            Positioned(
              bottom: 20.0,
              left: 0,
              right: 0,
              
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
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
                                decoration: InputDecoration(
                                  hintText: 'Enter destination',
                                ),
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    _searchPlace(value);
                                  }
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.search),
                              onPressed: _onSearch,
                            ),
                          ],
                        ),
                      ),
                      if (_suggestions.isNotEmpty)
                        Container(
                          height: 150.0,
                          child: ListView.builder(
                            itemCount: _suggestions.length,
                            itemBuilder: (context, index) {
                              final suggestion = _suggestions[index]['display_name'];
                              return ListTile(
                                title: Text(suggestion),
                                onTap: () {
                                  _updateMap(suggestion);
                                },
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          if (_destinationLocation != null)
            Positioned(
              bottom: 20.0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('From: Your Location'),
                            Text('To: $_destinationName'),
                            Text('Distance: ${calculateDistance(_currentLocation, _destinationLocation!)} km'),
                            SizedBox(height: 10),
                            if (_isStartRideVisible)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    onPressed: _startRide,
                                    child: Text('Start Ride'),
                                  ),
                                ],
                              ),
                            if (_rideStarted)
                              Column(
                                children: [
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
                                                child: Icon(Icons.check_circle, color: Colors.green),
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
                                                child: Icon(Icons.check_circle, color: Colors.green),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  if (_selectedRide.isNotEmpty)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed: _findDriver, // Trigger driver search
                                          child: Text('Find Driver'),
                                        ),
                                        SizedBox(width: 20),
                                        ElevatedButton(
                                          onPressed: _rideStarted ? _cancelRide : null, // Enable/disable based on ride status
                                          child: Text('Cancel Ride'),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                          ],
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

  double calculateDistance(LatLng start, LatLng end) {
    final distance = Geolocator.distanceBetween(start.latitude, start.longitude, end.latitude, end.longitude);
    return double.parse((distance / 1000).toStringAsFixed(2)); // Return as double
  }

  void _onSearch() {
    if (_searchController.text.isNotEmpty) {
      _updateMap(_searchController.text);
    }
  }

Future<void> _findDriver() async {
  // Check if a ride is selected
  if (_selectedRide.isEmpty) {
    print('No ride selected. Please select a ride.');
    return; // Exit the method if no ride is selected
  }

  // Print the current and destination locations along with the selected ride
  print('Ride started from ${_currentLocation.toString()} to ${_destinationLocation.toString()} with $_selectedRide');

  // Prepare the ride request data
final rideRequest = {
  "user_id": "6", // Use correct user ID
  "pickup_location": {
    "latitude": _currentLocation.latitude,
    "longitude": _currentLocation.longitude,
  },
  "dropoff_location": {
    "latitude": _destinationLocation!.latitude,
    "longitude": _destinationLocation!.longitude,
  },
  "preferred_vehicle_type": _selectedRide,
};


  try {
    // Send the ride request to the server
// Send the ride request to the server
final response = await http.post(
  Uri.parse('http://localhost:3000/api/ride-requests'), // Use HTTP instead of HTTPS
  headers: {'Content-Type': 'application/json'},
  body: json.encode(rideRequest),
);


// Check if the response status is 200 or 201
if (response.statusCode == 200 || response.statusCode == 201) {
  print('Ride request sent successfully!');
  
  // Navigate to the WaitingForDriverScreen once the ride request is sent
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => WaitingForDriverScreen()),
  );
  
  // Call the function to search for a driver
  _searchForDriver();
} else {
  print('Failed to send ride request: ${response.statusCode}');
  print('Response body: ${response.body}');
}

  } catch (e) {
    print('Error sending ride request: $e');
  }
}

Future<void> _searchForDriver() async {
  // Simulate a delay while searching for the driver (replace this with actual driver search logic)
  await Future.delayed(Duration(seconds: 3)); // Simulating a 3-second delay

  // Simulate a response from the server (replace this with actual logic)
  bool driverFound = await _simulateDriverSearch();

  if (driverFound) {
    // Notify the user that a driver was found (replace with actual driver data if needed)
    print('Driver found!');
    // Optionally, navigate to the next screen with driver details
    // Navigator.push(context, MaterialPageRoute(builder: (context) => DriverDetailsScreen(driverDetails)));
  } else {
    // Handle case where no driver was found
    print('No drivers available at the moment.');
  }
}

Future<bool> _simulateDriverSearch() async {
  // Simulate a driver search logic (return true if driver found, false if not)
  await Future.delayed(Duration(seconds: 1)); // Simulating network request
  return true; // Simulate that a driver was found
}
}
