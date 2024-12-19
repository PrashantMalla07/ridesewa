import 'package:flutter/material.dart';
import 'package:khalti_flutter/khalti_flutter.dart';
import 'package:ridesewa/view/profile/user_rating.dart';

class PaymentPage extends StatefulWidget {
  final double price;

  PaymentPage({required this.price});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? _selectedPaymentMethod = 'Khalti'; // Default payment method

  // Proceed to payment
  void _onProceedToPayment() {
    if (_selectedPaymentMethod == 'Khalti') {
      _payWithKhalti();
    } else if (_selectedPaymentMethod == 'Cash') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserRatingScreen()),
      );
    }
  }

  // Khalti payment integration
  void _payWithKhalti() {
    KhaltiScope.of(context).pay(
      config: PaymentConfig(
        amount: (widget.price * 100).toInt(), // Khalti requires the amount in paisa
        productIdentity: 'ride_payment_${DateTime.now().millisecondsSinceEpoch}',
        productName: 'Ride Payment',
      ),
      preferences: [
        PaymentPreference.khalti,
        PaymentPreference.eBanking,
        PaymentPreference.mobileBanking,
        PaymentPreference.connectIPS,
        PaymentPreference.sct,
      ],
      onSuccess: (success) {
        // Handle successful payment
        print('Payment Successful! Token: ${success.token}');
        _showPaymentSuccessDialog();
      },
      onFailure: (failure) {
        // Handle failed payment
        print('Payment Failed: ${failure.message}');
        _showPaymentFailureDialog();
      },
    );
  }

  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payment Successful'),
        content: Text('Your payment was successful.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserRatingScreen()),
              );
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPaymentFailureDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payment Failed'),
        content: Text('There was an issue with your payment.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Try Again'),
          ),
        ],
      ),
    );
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
