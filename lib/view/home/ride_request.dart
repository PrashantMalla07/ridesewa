import 'package:flutter/material.dart';
import 'package:ridesewa/Driver/accept_ride.dart';

class RideRequestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Incoming Ride Request'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Container showing pickup and drop-off details with action icons
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.grey[200],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4.0,
                    spreadRadius: 2.0,
                  ),
                ],
              ),
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Ride details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: Icon(Icons.location_on, color: Colors.red),
                          title: Text("Pickup Location: New Baneshwor"),
                          subtitle: Text("Distance: 5 km"),
                        ),
                        ListTile(
                          leading: Icon(Icons.flag, color: Colors.green),
                          title: Text("Drop-off Location: Thamel"),
                          subtitle: Text("Estimated Fare: Rs. 250"),
                        ),
                      ],
                    ),
                  ),
                  // Accept and Cancel icons
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check_circle, color: Colors.green, size: 30),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AcceptRideScreen()),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.cancel, color: Colors.red, size: 30),
                        onPressed: () {
                          Navigator.pop(context); // Return to the previous page (home page)
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
           
          ],
        ),
      ),
    );
  }
}
