import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ridesewa/Driver/pickup_dropoff_.dart';
import 'package:ridesewa/provider/widgets/custom_button.dart';

class ReachLocationScreen extends StatelessWidget {
  final LatLng driverLocation = LatLng(27.7172, 85.324); // Replace with dynamic driver location
  final LatLng passengerLocation = LatLng(27.7119, 85.3206); // Replace with dynamic passenger pickup location

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('At Pickup Location'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              flex: 3, // Increased space for the map
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: driverLocation,
                  initialZoom: 14.0,
                ),
                children: [
                  TileLayer (
                    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayer (
                    markers: [
                      Marker(
                        point: driverLocation,
                        child:  Icon(
                          Icons.directions_car,
                          color: Colors.blue,
                          size: 40,
                        ),
                      ),
                      Marker(
                        point: passengerLocation,
                        child:  Icon(
                          Icons.person_pin_circle,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          
            Spacer(),
            CustomButton(
              text: 'Passenger Picked Up',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PickupDropoffScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
