import 'package:flutter/material.dart';
import 'package:ridesewa/view/HomeView.dart';
import 'package:ridesewa/view/LogInView.dart';
import 'package:ridesewa/view/SignUpView.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ride Sharing App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeView(),
       routes: {
      '/login': (context) => LoginView(),
      '/signup': (context) => SignUpView(), 
      '/home': (context) => HomeView(),
      // other routes
    }, 
    );
  }
}
