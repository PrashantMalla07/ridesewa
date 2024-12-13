import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ridesewa/view/profile/userReview.dart';


class RideHistoryScreen extends StatefulWidget {
  final int userId;  // Accept userId

  RideHistoryScreen({required this.userId});  // Initialize userId in the constructor

  @override
  _RideHistoryScreenState createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  List<dynamic> rides = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRideHistory();
  }

  // Function to fetch ride history
  void _fetchRideHistory() async {
    try {
      final response = await Dio().get(
        'http://localhost:3000/api/rides/history?user_id=${widget.userId}',  // Pass userId in the URL
        options: Options(
          headers: {
            'Authorization': 'Bearer YOUR_JWT_TOKEN', // Use the correct token here
          },
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          rides = response.data;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showSnackBar('Failed to load ride history');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showSnackBar('Error fetching ride history: $e');
    }
  }

  // Function to show a snackbar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: Text('Ride History')),
      body: ListView.builder(
        itemCount: rides.length,
        itemBuilder: (context, index) {
          final ride = rides[index];
          return ListTile(
            title: Text('Ride #${ride['id']}'),
            subtitle: Text('From ${ride['pickup_location']} to ${ride['dropoff_location']}'),
            onTap: () {
              // Navigate to the review page for this ride
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReviewView(rideId: ride['id']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
