import 'package:flutter/material.dart';
import 'package:ridesewa/view/reg/LogInView.dart';
import 'package:ridesewa/view/reg/driver_login.dart';

class SelectionScreen extends StatefulWidget {
  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/logo.png',
              height: 180,
            ),
            SizedBox(height: 20),
            Text(
              'Are you a',
              style: TextStyle(
                fontSize: 24,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => DriverLogin(), // Replace with your UnAuth screen
                            ),);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(color: Colors.black),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    child: Center(
                      child: Text(
                        'Driver',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                GestureDetector(
                   onTap: () {
                    Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => LoginView(), // Replace with your UnAuth screen
                            ),);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(color: Colors.black),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    child: Center(
                      child: Text(
                        'Passenger',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Image.asset(
                  'assets/image.png',
                  height: 100,
                ),
                
              ],
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
