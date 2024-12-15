import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:ridesewa/provider/userprovider.dart';

class UserReviewPage extends StatefulWidget {
  @override
  _UserReviewPageState createState() => _UserReviewPageState();
}

class _UserReviewPageState extends State<UserReviewPage> {
  List<dynamic> _reviews = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final String? userid = userProvider.user?.id?.toString();

      if (userid == null) {
        setState(() {
          _errorMessage = 'User ID not found.';
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(Uri.parse('http://localhost:3000/api/reviews/user/$userid'));

      if (response.statusCode == 200) {
        setState(() {
          _reviews = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load reviews. Status code: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Reviews'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _reviews.isEmpty
                  ? Center(child: Text('No reviews available.'))
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
                                Text('Driver UID: ${review['driver_uid']}'),
                                Text('User Rating: ${review['user_rating']}'),
                                Text('User Review: ${review['user_review']}'),
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
