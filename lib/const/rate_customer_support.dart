import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';


class RateSupportExperiencePage extends StatefulWidget {
  @override
  _RateSupportExperiencePageState createState() =>
      _RateSupportExperiencePageState();
}

class _RateSupportExperiencePageState extends State<RateSupportExperiencePage> {
  double _rating = 0;
  String _comments = '';

  // Function to handle form submission
  void _submitRating() {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide a rating')),
      );
      return;
    }

    // Logic to submit the rating (e.g., sending to a backend or email)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Thank you for your feedback!')),
    );

    // Reset the form
    setState(() {
      _rating = 0;
      _comments = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rate Your Support Experience'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            // Star Rating Widget
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              itemSize: 40.0,
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            const SizedBox(height: 20),

            // Comments Text Field
            TextField(
              decoration: InputDecoration(
                labelText: 'Additional Comments (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              onChanged: (value) {
                setState(() {
                  _comments = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // Submit Button
            ElevatedButton(
              onPressed: _submitRating,
              child: Text('Submit Rating'),
            ),
          ],
        ),
      ),
    );
  }
}
