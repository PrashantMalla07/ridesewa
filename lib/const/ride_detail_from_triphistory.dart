import 'package:flutter/material.dart';

class RideDetailPage extends StatelessWidget {
  final Map<String, dynamic> ride;

  RideDetailPage({required this.ride});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ride Details'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      radius: 30,
                      child: Icon(Icons.directions_car, size: 30, color: Colors.white),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ride ID: ${ride['id']}',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Status: ${ride['status']}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: ride['status'] == 'Completed'
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            _buildDetailCard(
              icon: Icons.person,
              title: 'User ID',
              value: ride['user_id'].toString(),
            ),
            _buildDetailCard(
              icon: Icons.location_pin,
              title: 'Pickup Location',
              value:
                  '${ride['pickup'].latitude}, ${ride['pickup'].longitude}',
            ),
            _buildDetailCard(
              icon: Icons.location_on,
              title: 'Dropoff Location',
              value:
                  '${ride['dropoff'].latitude}, ${ride['dropoff'].longitude}',
            ),
            _buildDetailCard(
              icon: Icons.date_range,
              title: 'Created At',
              value: ride['created_at'],
            ),
            _buildDetailCard(
              icon: Icons.done_all,
              title: 'Completed At',
              value: ride['completed_at'],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({required IconData icon, required String title, required String value}) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, size: 32, color: Colors.blueAccent),
        title: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          value,
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
      ),
    );
  }
}
