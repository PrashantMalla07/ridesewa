import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:ridesewa/BaseUrl.dart';
import 'package:ridesewa/provider/driverprovider.dart';

class DriverReviewPage extends StatefulWidget {
  @override
  _DriverReviewPageState createState() => _DriverReviewPageState();
}

class _DriverReviewPageState extends State<DriverReviewPage> {
  List<dynamic> _reviews = [];

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    try {
      final driverProvider = Provider.of<DriverProvider>(context, listen: false);
      final String? driveruid = driverProvider.driver?.uid?.toString();

      final response = await http.get(Uri.parse('${BaseUrl.baseUrl}/api/reviews/driver/$driveruid'));

      if (response.statusCode == 200) {
        setState(() {
          _reviews = jsonDecode(response.body);
        });
      } else {
        throw Exception('Failed to load reviews with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Reviews'),
      ),
      body: _reviews.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _reviews.length,
              itemBuilder: (context, index) {
                final review = _reviews[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  elevation: 4.0,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16.0),
                    title: Text('Ride ID: ${review['ride_id']}',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4.0),
                        Text('User ID: ${review['user_id']}'),
                        Text('Driver Rating: ${review['driver_rating']}'),
                        
                        Text('Driver Review: ${review['driver_review']}'),
                        
                        Text('Date: ${review['created_at']}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
