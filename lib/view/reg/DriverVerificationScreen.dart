import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class DriverVerificationScreen extends StatefulWidget {
  @override
  _DriverVerificationScreenState createState() => _DriverVerificationScreenState();
}

class _DriverVerificationScreenState extends State<DriverVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Variables to store form data
  String? licenseNumber;
  String? citizenshipId;
  File? licensePhoto;
  File? citizenshipPhoto;
  String? vehicleType;
  String? vehicleColor;
  String? vehicleNumber;

  // Method to pick an image
  Future<void> _pickImage(String imageType) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (imageType == 'license') {
          licensePhoto = File(pickedFile.path);
        } else if (imageType == 'citizenship') {
          citizenshipPhoto = File(pickedFile.path);
        }
      });
    }
  }

  // Method to submit the form
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        // Update the URL if necessary
        final uri = Uri.parse('http://10.0.2.2:3000/api/verify-driver'); 

        final request = http.MultipartRequest('POST', uri)
          ..fields['licenseNumber'] = licenseNumber ?? ''
          ..fields['citizenshipId'] = citizenshipId ?? ''
          ..fields['vehicleType'] = vehicleType ?? ''
          ..fields['vehicleColor'] = vehicleColor ?? ''
          ..fields['vehicleNumber'] = vehicleNumber ?? '';

        // Add files to the request if they are not null
        if (licensePhoto != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'licensePhoto',
              licensePhoto!.path,
            ),
          );
        }
        if (citizenshipPhoto != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'citizenshipPhoto',
              citizenshipPhoto!.path,
            ),
          );
        }

        final response = await request.send();

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Driver verification submitted successfully')),
          );
          // Navigate or perform any other action
        } else {
          final responseBody = await response.stream.bytesToString();
          throw Exception('Failed to submit verification. Status code: ${response.statusCode}. Response: $responseBody');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Driver\'s License Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your driver\'s license number';
                  }
                  return null;
                },
                onSaved: (value) {
                  licenseNumber = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Citizenship ID'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Citizenship ID';
                  }
                  return null;
                },
                onSaved: (value) {
                  citizenshipId = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Vehicle Type'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your vehicle type';
                  }
                  return null;
                },
                onSaved: (value) {
                  vehicleType = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Vehicle Color'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your vehicle color';
                  }
                  return null;
                },
                onSaved: (value) {
                  vehicleColor = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Vehicle Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your vehicle number';
                  }
                  return null;
                },
                onSaved: (value) {
                  vehicleNumber = value;
                },
              ),
              SizedBox(height: 20),
              ListTile(
                title: Text('Upload Driver\'s License Photo'),
                subtitle: Text(licensePhoto != null ? 'Image selected' : 'No image selected'),
                trailing: IconButton(
                  icon: Icon(Icons.upload_file),
                  onPressed: () => _pickImage('license'),
                ),
              ),
              ListTile(
                title: Text('Upload Citizenship ID Photo'),
                subtitle: Text(citizenshipPhoto != null ? 'Image selected' : 'No image selected'),
                trailing: IconButton(
                  icon: Icon(Icons.upload_file),
                  onPressed: () => _pickImage('citizenship'),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Submit Verification'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
