import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ridesewa/Driver/rating_payment.dart';
import 'package:ridesewa/provider/widgets/custom_button.dart';

class PickupDropoffScreen extends StatelessWidget {
  final LatLng passengerLocation = LatLng(27.7172, 85.324); // Replace with dynamic passenger location
  final LatLng destinationLocation = LatLng(27.7119, 85.3206); // Replace with dynamic drop-off location

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Drop-off Passenger',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              flex: 3, // Increase flex for the map
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: passengerLocation,
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
                        point: passengerLocation,
                        child:  Icon(
                          Icons.person_pin_circle,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                      Marker(
                        point: destinationLocation,
                        child:  Icon(
                          Icons.location_on,
                          color: Colors.green,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Icon(Icons.directions_car, color: Colors.blue, size: 100),
                  SizedBox(height: 10),
                  Text(
                    "Driving to drop-off location...",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.grey[800]),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Passenger: Jane Smith",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]),
            ),
            Text(
              "Destination: Thamel, Kathmandu",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 10),
            LinearProgressIndicator(
              value: 0.8, // Adjust this value dynamically to show trip progress
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: CustomButton(
                text: 'Reached Drop-off Location',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RatingPaymentScreen()),
                  );
                },
              ),
            ),
          
          ],
        ),
      ),
    );
  }
}
