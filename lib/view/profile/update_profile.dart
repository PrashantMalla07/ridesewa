import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:ridesewa/BaseUrl.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    // Optionally, load existing profile data from local storage or API
  }

  // Pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Update the profile information
  Future<void> _updateProfile() async {
    final storage = FlutterSecureStorage();
    final userId = await storage.read(key: 'user_id'); // Get the logged-in user's ID

    // Check if the form is valid
    if (_formKey.currentState!.validate()) {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${BaseUrl.baseUrl}/updateProfile'),
      );
      request.fields['first_name'] = _firstNameController.text;
      request.fields['last_name'] = _lastNameController.text;
      request.fields['email'] = _emailController.text;
      request.fields['phone_number'] = _phoneController.text;
      request.fields['id'] = userId!;  // Use the user ID instead of uid

      // Attach the image if available
      if (_imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('image', _imageFile!.path));
      }

      // Send the request to the backend
      final response = await request.send();
      if (response.statusCode == 200) {
        // Successfully updated
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully!')));
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update profile.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile image
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _imageFile == null
                      ? NetworkImage('https://via.placeholder.com/150')
                      : FileImage(_imageFile!) as ImageProvider,
                ),
              ),
              SizedBox(height: 20),
              // Text Fields
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
                validator: (value) => value!.isEmpty ? 'Please enter your first name' : null,
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
                validator: (value) => value!.isEmpty ? 'Please enter your last name' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Please enter your email' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                validator: (value) => value!.isEmpty ? 'Please enter your phone number' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfile,
                child: Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
