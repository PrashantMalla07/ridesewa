import 'package:flutter/material.dart';
import 'package:khalti_flutter/khalti_flutter.dart'; // Import Khalti package
import 'package:provider/provider.dart';
import 'package:ridesewa/Dio/dio.dart'; // Ensure Dio setup is correct
import 'package:ridesewa/Driver/driver_homepage.dart'; // Ensure correct import path
import 'package:ridesewa/Driver/waiting_adminreq.dart'; // Ensure correct import path
import 'package:ridesewa/const/driver_resources.dart';
import 'package:ridesewa/const/help_support.dart';
import 'package:ridesewa/const/privacy_policy.dart';
import 'package:ridesewa/const/trip_history.dart';
import 'package:ridesewa/provider/driverprovider.dart';
import 'package:ridesewa/provider/ride_request.dart';
import 'package:ridesewa/provider/userprovider.dart';
import 'package:ridesewa/provider/walt_through_provider.dart';
import 'package:ridesewa/view/changePassword/changepasswrod.dart';
import 'package:ridesewa/view/home/HomeView.dart';
import 'package:ridesewa/view/home/adminDashboard.dart';
import 'package:ridesewa/view/introScreen/walkthrough.dart';
import 'package:ridesewa/view/profile/drawer.dart';
import 'package:ridesewa/view/profile/help_support_passenger.dart';
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
        ChangeNotifierProvider(create: (_) => RideStatusProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    return KhaltiScope(
      publicKey: '6e4cf1b7a2194a91896db5b6d394adf8',

      navigatorKey: navigatorKey, 
      enabledDebugging: true, 
      builder: (context, navigatorKey) {
        return MaterialApp(
          title: 'Ride Sharing App',
          navigatorKey: navigatorKey, 
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
            localizationsDelegates: const [
              KhaltiLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('ne', 'NP'),
            ],
          home: WalkThrough(),
          routes: {
            '/login': (context) => const LoginView(),
            '/driver-login': (context) => DriverLogin(),
            '/signup': (context) => SignUpView(),
            '/home': (context) => HomeView(),
            '/profile': (context) => UserProfilePage(),
            '/change-password': (context) => ChangePasswordScreen(),
            '/drawer': (context) => AppDrawer(),
            '/driverSignup': (context) => DriverRegisterScreen(),
            '/admin-dashboard': (context) => AdminDashboard(),
            '/driver-home': (context) => DriverHomeView(),
            '/waiting-for-approval': (context) => WaitingForadminapproval(),
            '/help-support': (context) => HelpSupportPage(),
            '/help-support-passenger': (context) => HelpSupportPassengerPage(),
            '/privacy-policy': (context) => PrivacyPolicyPage(),
            '/resources': (context) => DriverResourcesPage(),
            '/trip-history': (context) => RideHistoryDrawer(),
          },
        );
      },
    );
  }
}
