import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:ridesewa/provider/driverprovider.dart';

class DriverProfilePage extends StatefulWidget {
  @override
  _DriverProfilePageState createState() => _DriverProfilePageState();
}

class _DriverProfilePageState extends State<DriverProfilePage> {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final ImagePicker _picker = ImagePicker();

  Map<String, dynamic>? _driverData;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchDriverProfile();
  }

  Future<void> _fetchDriverProfile() async {
    final driverProvider = Provider.of<DriverProvider>(context, listen: false);
    final String? driveruid = driverProvider.driver?.uid?.toString();
    if (driveruid == null) {
      setState(() {
        _errorMessage = 'Driver UID is not available.';
        _isLoading = false;
      });
      return;
    }

    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await _dio.get(
        'http://localhost:3000/driver/profile/$driveruid',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      setState(() {
        _driverData = response.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile. Please try again later.';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Logic to handle the selected image
    }
  }

  void _showImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Image.network(imageUrl, fit: BoxFit.cover),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Profile'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _driverData != null
                  ? SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Column(
                        children: [
                          Center(
                            child: _driverData!['driver_photo'] != null &&
                                    _driverData!['driver_photo'].isNotEmpty
                                ? ClipOval(
                                    child: Image.network(
                                      _driverData!['driver_photo'],
                                      height: 150,
                                      width: 150,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : _buildPlaceholderProfile(),
                          ),
                          SizedBox(height: 16),
                          _buildProfileDetail('Name:', '${_driverData!['first_name']} ${_driverData!['last_name']}'),
                          _buildProfileDetail('Email:', _driverData!['email']),
                          _buildProfileDetail('Phone:', _driverData!['phone_number']),
                          _buildProfileDetail('Vehicle Type:', _driverData!['vehicle_type'] ?? 'N/A'),
                          _buildProfileDetail('Vehicle Color:', _driverData!['vehicle_color'] ?? 'N/A'),
                          _buildProfileDetail('License Number:', _driverData!['license_number'] ?? 'N/A'),
                          _buildProfileDetail('Citizenship Number:', _driverData!['citizenship_id'] ?? 'N/A'),
                          SizedBox(height: 16),
                          _buildImageSection('License Images', _driverData!['license_photo'], context),
                          SizedBox(height: 16),
                          _buildImageSection('Citizenship Images', _driverData!['citizenship_photo'], context),
                        ],
                      ),
                    )
                  : Center(child: Text('No data available')),
    );
  }

  Widget _buildPlaceholderProfile() {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipOval(
          child: Container(
            color: Colors.grey[400],
            height: 150,
            width: 150,
            child: Icon(
              Icons.camera_alt,
              size: 50,
              color: Colors.white,
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: GestureDetector(
            onTap: _pickImage,
            child: Icon(
              Icons.edit,
              size: 24,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileDetail(String label, String value) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(String label, String? imageUrl, BuildContext context) {
    return GestureDetector(
      onTap: () => _showImage(context, imageUrl ?? ''),
      child: imageUrl != null && imageUrl.isNotEmpty
          ? Text(
              label,
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            )
          : Text('No $label'),
    );
  }
}
