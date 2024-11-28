import 'package:flutter/material.dart';
import 'package:ridesewa/Driver/rating.dart';

class PaymentPage extends StatefulWidget {
  final double price;

  PaymentPage({required this.price});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? _selectedPaymentMethod = 'Khalti'; // Default payment method

  // Simulate Khalti integration and Cash selection
  void _onProceedToPayment() {
    if (_selectedPaymentMethod == 'Khalti') {
      // Simulate opening Khalti payment page
      // For now, this is a simple placeholder
      // You can integrate Khalti's SDK here for real payment.
      print('Proceeding with Khalti Payment...');
      // Open Khalti payment method (this would usually open a Khalti SDK integration)
      // Here you might navigate to Khalti payment page or call an API for Khalti payment
    } else if (_selectedPaymentMethod == 'Cash') {
      // Navigate to Rating page if Cash is selected
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RatingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payment Summary',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.teal,
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.teal[50],
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Ride Payment Details',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Price',
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                      Text(
                        'NPR ${widget.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Divider(),
                  SizedBox(height: 10),
                  // Payment Method Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Payment Method',
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                      // Payment Method Selector
                      DropdownButton<String>(
                        value: _selectedPaymentMethod,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedPaymentMethod = newValue;
                          });
                        },
                        items: [
                          DropdownMenuItem(
                            value: 'Khalti',
                            child: Row(
                              children: [
                                Icon(Icons.payment, color: Colors.teal),
                                SizedBox(width: 8),
                                Text('Khalti'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Cash',
                            child: Row(
                              children: [
                                Icon(Icons.money, color: Colors.teal),
                                SizedBox(width: 8),
                                Text('Cash'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Divider(),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _onProceedToPayment,
                    child: Text(
                      'Proceed to Payment',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
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

