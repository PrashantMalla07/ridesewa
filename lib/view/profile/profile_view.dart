import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:ridesewa/BaseUrl.dart';
import 'package:ridesewa/provider/userprovider.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  Map<String, dynamic>? _userData; // Holds user data when fetched
  String? _errorMessage; // Holds error message if fetching fails
  bool _isLoading = true; // Flag to track loading state
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile(); // Fetch user profile when the widget is initialized
  }

  Future<void> _fetchUserProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false); // Access user provider
    final String? userId = userProvider.user?.id.toString(); // Get user ID
    if (userId == null) {
      // If user ID is null, show error
      setState(() {
        _errorMessage = 'User ID is not available.';
        _isLoading = false;
      });
      return;
    }

    try {
      // Fetch user profile data from the backend
      final token = await _storage.read(key: 'auth_token'); // Read token from secure storage
      final response = await _dio.get(
        '${BaseUrl.baseUrl}/user/profile/$userId',
        options: Options(headers: {'Authorization': 'Bearer $token'}), // Pass token in header
      );
      setState(() {
        _userData = response.data; // Update user data
        _isLoading = false; // Stop loading indicator
      });
    } catch (e) {
      // Handle errors
      setState(() {
        _errorMessage = 'Failed to load profile. Please try again later.';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Logic to handle the selected image (you can implement this)
    }
  }

  @override
  Widget build(BuildContext context) {
    // Handle loading state, error messages, and display user data
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : (_errorMessage != null && _errorMessage!.isNotEmpty)
              ? Center(child: Text(_errorMessage!))
              : _userData != null
                  ? SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Column(
                        children: [
                          Center(
                            child: _userData!['image_url'] != null &&
                                    _userData!['image_url'].isNotEmpty
                                ? ClipOval(
                                    child: Image.network(
                                      _userData!['image_url'],
                                      height: 150,
                                      width: 150,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : _buildPlaceholderProfile(),
                          ),
                          SizedBox(height: 16),
                          _buildProfileDetail('Name:', '${_userData!['first_name']} ${_userData!['last_name']}'),
                          _buildProfileDetail('Email:', _userData!['email']),
                          _buildProfileDetail('Phone:', _userData!['phone_number']),
                          
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
}
