// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:latlong2/latlong.dart';

// class DestinationView extends StatelessWidget {
//   final String destination;
//   final LatLng currentLocation;
//   final LatLng destinationLocation;

//   DestinationView({
//     required this.destination,
//     required this.currentLocation,
//     required this.destinationLocation,
//   });

//   double _calculateDistance() {
//     final distanceInMeters = Geolocator.distanceBetween(
//       currentLocation.latitude,
//       currentLocation.longitude,
//       destinationLocation.latitude,
//       destinationLocation.longitude,
//     );
//     return distanceInMeters / 1000; // Convert to kilometers
//   }

//   @override
//   Widget build(BuildContext context) {
//     final distance = _calculateDistance();

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Destination'),
//         backgroundColor: Colors.blue,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Selected Destination:',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             Text(
//               destination,
//               style: TextStyle(fontSize: 20),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 30),
//             Text(
//               'Distance from Current Location:',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             Text(
//               '${distance.toStringAsFixed(2)} km',
//               style: TextStyle(fontSize: 20),
//             ),
//             SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context); // Navigate back to the previous screen
//               },
//               child: Text('Back to Map'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
