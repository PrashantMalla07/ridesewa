import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridesewa/provider/userprovider.dart'; // If you're using provider for user state


class ReviewView extends StatefulWidget {
  final int rideId;

  ReviewView({required this.rideId});

  @override
  _ReviewViewState createState() => _ReviewViewState();
}

class _ReviewViewState extends State<ReviewView> {
  String review = '';
  int rating = 0;
  bool isLoading = true;
  bool reviewNotFound = false;

  @override
  void initState() {
    super.initState();
    _fetchReview();
  }

  void _fetchReview() async {
    final user = Provider.of<UserProvider>(context, listen: false).user; // Get the user from provider
    final userId = user?.id; // Assuming `user.id` is the current logged-in user's ID

    if (userId == null) {
      setState(() {
        isLoading = false;
      });
      _showSnackBar('User not logged in');
      return;
    }

    try {
      final response = await Dio().get(
        'http://localhost:3000/api/review/${widget.rideId}', // Pass rideId
        queryParameters: {'userId': userId}, // Pass userId as a query parameter
        options: Options(
          headers: {
            'Authorization': 'Bearer YOUR_JWT_TOKEN', // Pass the token if needed
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          setState(() {
            review = data['review'];
            rating = data['rating'];
            isLoading = false;
            reviewNotFound = false;
          });
        } else {
          setState(() {
            reviewNotFound = true;
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
        _showSnackBar('Review not found!');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showSnackBar('Error: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (reviewNotFound) {
      return Scaffold(
        appBar: AppBar(title: Text('Review for Ride #${widget.rideId}')),
        body: Center(
          child: Text('No review found for this ride by the current user.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Review for Ride #${widget.rideId}')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rating: $rating/5'),
            SizedBox(height: 8),
            Text('Review: $review'),
          ],
        ),
      ),
    );
  }
}
