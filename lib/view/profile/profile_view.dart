import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/io_client.dart' as http;
import 'package:http_parser/http_parser.dart'; // Correct import for MediaType
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:ridesewa/provider/userprovider.dart';

class ProfileView extends StatefulWidget {
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  String? profileImageUrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = Provider.of<UserProvider>(context).user;
    if (user != null) {
      _fetchProfileImage();
    }
  }

  HttpClient createHttpClient() {
    final client = HttpClient();
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => true; // Trust all certificates
    client.connectionTimeout = const Duration(seconds: 30); // Increase the timeout
    return client;
  }

  // Fetch profile image
  void _fetchProfileImage() async {
    final user = Provider.of<UserProvider>(context, listen: false).user!;
    final userId = user?.uid ?? 0;

    print('User ID in _fetchProfileImage: $userId');

    try {
      // Use 10.0.2.2 for Android emulator
      final ioClient = http.IOClient(createHttpClient());

      final response = await ioClient.post(
          Uri.parse('http://localhost:3000/api/user/$userId/image'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          profileImageUrl = data['image_url'];
        });
      } else {
        _showSnackBar('Failed to fetch profile image.');
      }
    } catch (e) {
      _showSnackBar('An error occurred: $e');
    }
  }

 void _uploadProfileImage() async {
  final user = Provider.of<UserProvider>(context, listen: false).user!; // Get user details
  final userId = user.uid;

  if (userId == null) {
    _showSnackBar('User ID is null. Cannot upload image.');
    return;
  }

  final picker = ImagePicker();

  try {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Compress image before uploading (optional step, only for supported platforms)
      Uint8List? compressedImage;

      if (!foundation.kIsWeb) {
        try {
          compressedImage = await FlutterImageCompress.compressWithFile(
            pickedFile.path,
            minWidth: 800,
            minHeight: 600,
            quality: 80,
          );
        } catch (e) {
          // Log and notify user if compression fails
          print('Error during image compression: $e');
          _showSnackBar('Image compression failed. Proceeding without compression.');
        }
      }

      // Initialize Dio for HTTP/HTTPS requests
      dio.Dio dioClient = dio.Dio();
      dioClient.options.baseUrl = 'http://localhost:3000'; // Use 10.0.2.2 for Android emulator

      // Set the request timeouts
      dioClient.options.connectTimeout = const Duration(seconds: 15); // Connection timeout
      dioClient.options.receiveTimeout = const Duration(seconds: 4); // Response timeout

      // Set the Content-Type header for multipart form data
      dioClient.options.headers = {
        "Content-Type": "multipart/form-data", // Set content type for the multipart form data
      };

      // Determine the MIME type of the picked file using http_parser
      final mimeType = lookupMimeType(pickedFile.path);

      // Fallback if MIME type is null
      final contentType = mimeType != null
          ? MediaType.parse(mimeType) // Correct way to parse MIME type with http_parser
          : MediaType('image', 'jpeg'); // Default to 'image/jpeg' if mime type is unknown

      // Create a multipart form for the image upload
      final formData = dio.FormData.fromMap({
        'image': await dio.MultipartFile.fromFile(
          pickedFile.path,
          contentType: contentType, // Set content type dynamically
        ),
      });

      // If compression was successful, use the compressed image for upload
      if (compressedImage != null) {
        formData.files.add(MapEntry(
          'image',
          dio.MultipartFile.fromBytes(compressedImage, filename: pickedFile.name),
        ));
      }

      // Make the POST request to upload the image
      final response = await dioClient.post(
        '/api/user/$userId/upload-image', // Use relative path as baseUrl is set
        data: formData,
      );

      // Handle response
      if (response.statusCode == 200) {
        _fetchProfileImage(); // Call this method to refresh the profile image after upload
        _showSnackBar('Profile image uploaded successfully!');
      } else {
        _showSnackBar('Failed to upload image: ${response.data}');
        print('Server response: ${response.data}');
      }
    } else {
      _showSnackBar('No image selected.');
    }
  } catch (e, stackTrace) {
    _showSnackBar('An error occurred while uploading the image: $e');
    print('Error: $e\nStackTrace: $stackTrace');
  }
}




  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    if (user == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
              ),
              Positioned(
                top: 50,
                child: GestureDetector(
                  onTap: _uploadProfileImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: profileImageUrl != null
                        ? NetworkImage(profileImageUrl!)
                        : null,
                    child: profileImageUrl == null
                        ? Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Colors.blueAccent,
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('ID', user.uid.toString()),
                    Divider(),
                    _buildInfoRow('First Name', user.firstName),
                    Divider(),
                    _buildInfoRow('Last Name', user.lastName),
                    Divider(),
                    _buildInfoRow('Email', user.email),
                    Divider(),
                    _buildInfoRow('Phone', user.phoneNumber),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
