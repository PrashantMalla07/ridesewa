import 'package:flutter/material.dart';
import 'package:ridesewa/Driver/reach_location.dart';
import 'package:ridesewa/provider/widgets/custom_button.dart';


class AcceptRideScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ride Accepted', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 2, blurRadius: 7),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset('assets/bike.png', height: 150), // Replace with your image
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Heading to Pickup Location...",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              "Estimated Arrival Time: 10 mins",
              style: TextStyle(fontSize: 16, color: Colors.blueAccent),
            ),
            SizedBox(height: 10),
            Text(
              "Driver: John Doe",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800]),
            ),
            Text(
              "Vehicle: White Toyota Prius - Plate: ABC1234",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 20),
            LinearProgressIndicator(
              value: 0.5, // You can control the progress value here dynamically
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: CustomButton(
                text: 'Reached Pickup Location',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ReachLocationScreen()),
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
