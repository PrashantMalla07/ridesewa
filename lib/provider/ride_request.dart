import 'package:flutter/foundation.dart';

class RideStatusProvider with ChangeNotifier {
  bool _rideStarted = false;

  bool get rideStarted => _rideStarted;

  void startRide() {
    _rideStarted = true;
    notifyListeners(); // Notify listeners about the change
  }
}
