import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geocoding/geocoding.dart'; // Import geocoding package
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  LatLng _currentLocation = LatLng(28.2096, 83.9856); // Default location (Pokhara)
  LatLng? _destinationLocation; // Variable to store destination location
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  double _currentZoom = 15.0;

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
      // Handle errors if needed
      print('Error getting current location: $e');
    }
  }

  void _zoomIn() {
    setState(() {
      _currentZoom = (_currentZoom < 20.0) ? _currentZoom + 1.0 : _currentZoom;
      _mapController.move(_currentLocation, _currentZoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentZoom = (_currentZoom > 1.0) ? _currentZoom - 1.0 : _currentZoom;
      _mapController.move(_currentLocation, _currentZoom);
    });
  }

  Future<List<String>> _getSuggestions(String query) async {
    final response = await http.get(Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=YOUR_GOOGLE_PLACES_API_KEY',
    ));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final predictions = data['predictions'] as List;
      return predictions.map((prediction) => prediction['description'] as String).toList();
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  Future<void> _onSuggestionSelected(String suggestion) async {
    try {
      List<Location> locations = await locationFromAddress(suggestion);
      if (locations.isNotEmpty) {
        setState(() {
          _destinationLocation = LatLng(locations.first.latitude, locations.first.longitude);
          if (_destinationLocation != null) {
            _mapController.move(_destinationLocation!, _currentZoom);
          }
        });
      } else {
        print('No locations found for the query.');
      }
    } catch (e) {
      print('Error searching destination: $e');
    }
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Implement navigation or any desired behavior here
          },
        ),
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
                        Icons.place,
                        color: Colors.red,
                        size: 40.0,
                      ),
                  ),
                  if (_destinationLocation != null) // Only show destination marker if location is available
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
          ),
          Positioned(
            top: 20.0,
            left: 20.0,
            right: 20.0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TypeAheadField<String>(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search & Setup drop-off location',
                    border: InputBorder.none,
                  ),
                ),
                suggestionsCallback: _getSuggestions,
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion),
                  );
                },
                onSuggestionSelected: _onSuggestionSelected,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.blue,
            onPressed: _getCurrentLocation,
            child: Icon(Icons.my_location),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _zoomIn,
            child: Icon(Icons.zoom_in),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _zoomOut,
            child: Icon(Icons.zoom_out),
          ),
        ],
      ),
    );
  }
}
