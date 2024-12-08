import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridesewa/Dio/dio.dart'; // Ensure Dio setup is correct
import 'package:ridesewa/Driver/driver_homepage.dart'; // Ensure correct import path
import 'package:ridesewa/Driver/waiting_adminreq.dart'; // Ensure correct import path
import 'package:ridesewa/provider/driverprovider.dart';
import 'package:ridesewa/provider/userprovider.dart';
import 'package:ridesewa/provider/walt_through_provider.dart';
import 'package:ridesewa/view/changePassword/changepasswrod.dart';
import 'package:ridesewa/view/home/HomeView.dart';
import 'package:ridesewa/view/home/adminDashboard.dart';
import 'package:ridesewa/view/profile/drawer.dart';
import 'package:ridesewa/view/profile/profile_view.dart';
import 'package:ridesewa/view/reg/LogInView.dart';
import 'package:ridesewa/view/reg/SignUpView.dart';
import 'package:ridesewa/view/reg/driver_login.dart';
import 'package:ridesewa/view/reg/driver_reg.dart'; 

void main() {
  setupDio(); // Ensure Dio setup function is defined correctly
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => DriverProvider()),
        ChangeNotifierProvider(create: (_) => WalkthroughProvider()),
      ],
      child: MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  @override
Widget build(BuildContext context) {
  // // Assuming `UserProvider` has a method `isLoggedIn`
  // final userProvider = Provider.of<UserProvider>(context, listen: true);

  return MaterialApp(
    title: 'Ride Sharing App',
    theme: ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    home: DriverLogin(),
    routes: {
      '/login': (context) => const LoginView(),
      '/driver-login': (context) => DriverLogin(),
      '/signup': (context) => SignUpView(),
      '/home': (context) => HomeView(),
      '/profile': (context) => ProfileView(),
      '/change-password': (context) => ChangePasswordScreen(),
      '/drawer': (context) => AppDrawer(),
      '/driverSignup': (context) => DriverRegisterScreen(),
      '/admin-dashboard': (context) => AdminDashboard(),
      '/driver-home': (context) => DriverHomeView(),
      '/waiting-for-approval': (context) => WaitingForadminapproval(),
    },
  );
}
}