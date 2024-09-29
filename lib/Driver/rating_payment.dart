import 'package:flutter/material.dart';
import 'package:ridesewa/provider/widgets/custom_button.dart';

class RatingPaymentScreen extends StatefulWidget {
  @override
  _RatingPaymentScreenState createState() => _RatingPaymentScreenState();
}

class _RatingPaymentScreenState extends State<RatingPaymentScreen> {
  double _rating = 3.0;
  TextEditingController _fareController = TextEditingController();
  String _selectedPaymentMethod = 'Cash'; // Default payment method

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complete Ride'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _fareController,
              decoration: InputDecoration(
                labelText: 'Enter Fare Received',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            Text('Rate the Passenger:', style: TextStyle(fontSize: 18)),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.yellow[700],
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1.0;
                    });
                  },
                );
              })..addAll([
                IconButton(
                  icon: Icon(
                    Icons.star_half,
                    color: _rating % 1 == 0.5 ? Colors.yellow[700] : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = 0.5 + (_rating.toInt());
                    });
                  },
                ),
              ]),
            ),
            
            Spacer(),
            CustomButton(
              text: 'Complete Ride',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ride Completed! Fare: Rs. ${_fareController.text}, Rating: $_rating stars, Payment Method: $_selectedPaymentMethod')),
                );
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }
}
