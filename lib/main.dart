import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridesewa/controller/app_drawer_controller.dart';
import 'package:ridesewa/view/HomeView.dart';
import 'package:ridesewa/view/LogInView.dart';
import 'package:ridesewa/view/SignUpView.dart';
import 'package:ridesewa/view/profile_view.dart';



void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppDrawerController()),
      ],
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
      // other routes
    }, 
    );
  }
}
