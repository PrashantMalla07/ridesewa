import 'package:flutter/material.dart';
import 'package:ridesewa/provider/widgets/custom_button.dart';

class UserRatingScreen extends StatefulWidget {
  @override
  _UserRatingScreenState createState() => _UserRatingScreenState();
}

class _UserRatingScreenState extends State<UserRatingScreen> {
  double _experienceRating = 0.0;
  double _driverRating = 0.0;
  TextEditingController _feedbackController = TextEditingController();
  

  // Predefined feedback suggestions
  List<String> feedbackSuggestions = [
    "Great ride experience",
    "Friendly driver",
    "Clean vehicle",
    "Punctual driver",
    "Smooth ride",
    "Driver was very helpful",
    "Vehicle was comfortable",
    "Would recommend to others",
    "Good communication",
    "Quick and efficient service"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('How was the trip?'),
        centerTitle: true,
        backgroundColor:Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rate the Experience
              Text('Please rate the experience', style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              _buildStarRating(_experienceRating, (rating) {
                setState(() {
                  _experienceRating = rating;
                });
              }),
              SizedBox(height: 20),
              
              // Rate the Driver
              Text('Please rate the driver', style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              _buildStarRating(_driverRating, (rating) {
                setState(() {
                  _driverRating = rating;
                });
              }),
              
              // Feedback Section
              SizedBox(height: 20),
              Text('Leave a feedback', style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              TextField(
                controller: _feedbackController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Write your feedback here...",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                children: feedbackSuggestions.map((suggestion) {
                  return ChoiceChip(
                    label: Text(suggestion),
                    selected: false,
                    onSelected: (selected) {
                      setState(() {
                        _feedbackController.text = suggestion;
                      });
                    },
                  );
                }).toList(),
              ),
              
              // Payment Method
             
             

              SizedBox(height: 20),
              // Submit Button
              CustomButton(
                text: 'Submit',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Experience Rating: $_experienceRating stars\nDriver Rating: $_driverRating stars\nFeedback: ${_feedbackController.text}',
                      ),
                    ),
                  );
                  Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStarRating(double currentRating, Function(double) onRatingChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        double starValue = index + 1;
        return GestureDetector(
          onTap: () {
            onRatingChanged(starValue);
          },
          child: Icon(
            starValue <= currentRating ? Icons.star : Icons.star_border,
            color: Colors.yellow[700],
            size: 40,
          ),
        );
      })..addAll([
        GestureDetector(
          onTap: () {
            onRatingChanged(currentRating % 1 == 0.5 ? currentRating.toInt() + 1.0 : currentRating + 0.5);
          },
          child: Icon(
            currentRating % 1 == 0.5 ? Icons.star_half : Icons.star_border,
            color: Colors.yellow[700],
            size: 40,
          ),
        ),
      ]),
    );
  }
}
