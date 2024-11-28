import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridesewa/Dio/dio.dart'; // Ensure Dio setup is correct
import 'package:ridesewa/Driver/driver_homepage.dart'; // Ensure correct import path
import 'package:ridesewa/Driver/waiting_adminreq.dart'; // Ensure correct import path
import 'package:ridesewa/provider/userprovider.dart';
import 'package:ridesewa/view/changePassword/changepasswrod.dart';
import 'package:ridesewa/view/home/HomeView.dart';
import 'package:ridesewa/view/home/adminDashboard.dart';
import 'package:ridesewa/view/profile/drawer.dart';
import 'package:ridesewa/view/profile/profile_view.dart';
import 'package:ridesewa/view/reg/DriverVerificationScreen.dart';
import 'package:ridesewa/view/reg/LogInView.dart';
import 'package:ridesewa/view/reg/SignUpView.dart'; 

void main() {
  setupDio(); // Ensure Dio setup function is defined correctly
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MyApp(),
    ),
  );
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
      home: LoginView(), // Home page is LoginView, you can change it based on user state
      routes: {
        '/login': (context) => LoginView(),
        '/signup': (context) => SignUpView(),
        '/home': (context) => HomeView(),
        '/profile': (context) => ProfileView(),
        '/change-password': (context) => ChangePasswordScreen(),
        '/drawer': (context) => AppDrawer(), // Make sure this is used as part of Scaffold
        '/driver-verification': (context) => DriverVerificationScreen(),
        '/admin-dashboard': (context) => AdminDashboard(),
        '/driver-home': (context) => DriverHomeView(),
        '/waiting-for-approval': (context) => WaitingForadminapproval(),
        // '/accept-ride': (context) => RideRequestScreen(),
        // other routes...
      },
    );
  }
}
