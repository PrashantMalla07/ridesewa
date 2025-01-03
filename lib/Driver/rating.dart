import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:ridesewa/BaseUrl.dart';
import 'package:ridesewa/provider/driverprovider.dart';
import 'package:ridesewa/provider/widgets/custom_button.dart';
class RatingScreen extends StatefulWidget {
  @override
  _RatingScreenState createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  double _experienceRating = 0.0;
  double _driverRating = 0.0;
  TextEditingController _feedbackController = TextEditingController();
  

  // Predefined feedback suggestions
  List<String> feedbackSuggestions = [
    "Great ride experience",
    "User was polite and respectful" ,
    "Clear instructions about destination",
    "Easy to communicate with",
    "Friendly and cooperative",
    "Treated the vehicle with care",
    "Smooth and hassle-free trip",
    "Helpful and understanding",
    "Good payment behavior",
    "Understanding in case of delays",
    "Did not distract the driver",

  ];
  Future<void> submitFeedback() async {
    final feedbackData = {
       
      "driver_rating": _driverRating,
      "driver_review": _feedbackController.text,
    };
    final driverProvider = Provider.of<DriverProvider>(context, listen: false);
      final String? driveruid = driverProvider.driver?.uid?.toString();
    final url = '${BaseUrl.baseUrl}/api/reviews';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Feedback submitted successfully')),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit feedback')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  

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
              Text('Please rate the User', style: TextStyle(fontSize: 18)),
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
                  Navigator.popUntil(context, (route) => route.isFirst);
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
