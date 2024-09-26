import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridesewa/Dio/dio.dart';
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
  setupDio();
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
      home: LoginView(),
      routes: {
        '/login': (context) => LoginView(),
        '/signup': (context) => SignUpView(), 
        '/home': (context) => HomeView(),
        '/profile': (context) => ProfileView(),
        '/change-password': (context) => ChangePasswordScreen(),
        '/drawer': (context) => AppDrawer(),
        '/driver-verification': (context) => DriverVerificationScreen(),
        '/admin-dashboard': (context) => AdminDashboard(), 
        // other routes
      }, 
    );
  }
}
