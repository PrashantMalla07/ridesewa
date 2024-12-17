import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:ridesewa/BaseUrl.dart';
import 'package:ridesewa/provider/driverprovider.dart';

class DriverRatingPage extends StatefulWidget {
  @override
  _DriverRatingPageState createState() => _DriverRatingPageState();
}

class _DriverRatingPageState extends State<DriverRatingPage> {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  double? _averageRating;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchAverageDriverRating();
  }

  Future<void> _fetchAverageDriverRating() async {
    final driverProvider = Provider.of<DriverProvider>(context, listen: false);
    final String? driverUid = driverProvider.driver?.uid?.toString();
    if (driverUid == null) {
      setState(() {
        _errorMessage = 'Driver UID is not available.';
        _isLoading = false;
      });
      return;
    }

    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await _dio.get(
        '${BaseUrl.baseUrl}/api/driver_ratings/driver/$driverUid',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        final dynamic averageRating = response.data['average_rating'];
        if (averageRating is num || (averageRating is String && double.tryParse(averageRating) != null)) {
          setState(() {
            _averageRating = double.parse(averageRating.toString());
            _isLoading = false;
          });
        } else {
          throw Exception('Invalid average rating value');
        }
      } else {
        throw Exception('Failed to load average rating with status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load average rating. Please try again later. Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Rating'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _averageRating != null
                  ? Center(child: Text(' $_averageRating'))
                  : Center(child: Text('No rating data available')),
    );
  }
}
