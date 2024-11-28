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

  String? licenseNumber, citizenshipId, vehicleType, vehicleColor, vehicleNumber;
  File? licensePhoto, citizenshipPhoto, driverPhoto;
  bool showDriverDetails = false, showVehicleDetails = false;
  bool isDriver = false;

  // Image Picker
  Future<void> _pickImage(String imageType) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (imageType == 'license') licensePhoto = File(pickedFile.path);
        if (imageType == 'citizenship') citizenshipPhoto = File(pickedFile.path);
        if (imageType == 'driver') driverPhoto = File(pickedFile.path);
      });
    }
  }

  // Submit Form
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        final uri = Uri.parse('http://localhost:3000/api/switch-to-driver');
        final request = http.MultipartRequest('POST', uri)
          ..fields['userId'] = '6' // Replace with dynamic user ID
          ..fields['licenseNumber'] = licenseNumber ?? ''
          ..fields['citizenshipId'] = citizenshipId ?? ''
          ..fields['vehicleType'] = vehicleType ?? ''
          ..fields['vehicleColor'] = vehicleColor ?? ''
          ..fields['vehicleNumber'] = vehicleNumber ?? '';

        if (licensePhoto != null) {
          request.files.add(await http.MultipartFile.fromPath('licensePhoto', licensePhoto!.path));
        }
        if (citizenshipPhoto != null) {
          request.files.add(await http.MultipartFile.fromPath('citizenshipPhoto', citizenshipPhoto!.path));
        }
        if (driverPhoto != null) {
          request.files.add(await http.MultipartFile.fromPath('driverPhoto', driverPhoto!.path));
        }

        final response = await request.send();

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Verification Submitted!')));
        } else {
          final responseBody = await response.stream.bytesToString();
          throw Exception('Submission failed. Response: $responseBody');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Driver Verification')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Driver Certificate',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SwitchListTile(
                title: Text('Enter Driver Details'),
                value: showDriverDetails,
                onChanged: (val) => setState(() => showDriverDetails = val),
              ),
              if (showDriverDetails)
                Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Driver\'s License Number'),
                      validator: (value) => value == null || value.isEmpty ? 'Enter license number' : null,
                      onSaved: (value) => licenseNumber = value,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Citizenship ID'),
                      validator: (value) => value == null || value.isEmpty ? 'Enter citizenship ID' : null,
                      onSaved: (value) => citizenshipId = value,
                    ),
                  ],
                ),
              Divider(),
              Text(
                'Vehicle Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SwitchListTile(
                title: Text('Enter Vehicle Details'),
                value: showVehicleDetails,
                onChanged: (val) => setState(() => showVehicleDetails = val),
              ),
              if (showVehicleDetails)
                Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Vehicle Type'),
                      validator: (value) => value == null || value.isEmpty ? 'Enter vehicle type' : null,
                      onSaved: (value) => vehicleType = value,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Vehicle Color'),
                      validator: (value) => value == null || value.isEmpty ? 'Enter vehicle color' : null,
                      onSaved: (value) => vehicleColor = value,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Vehicle Number'),
                      validator: (value) => value == null || value.isEmpty ? 'Enter vehicle number' : null,
                      onSaved: (value) => vehicleNumber = value,
                    ),
                  ],
                ),
              Divider(),
              Text(
                'Upload Images',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListTile(
                title: Text('Driver\'s License Image'),
                subtitle: Text(licensePhoto != null ? 'Image Selected' : 'No image selected'),
                trailing: IconButton(icon: Icon(Icons.upload), onPressed: () => _pickImage('license')),
              ),
              ListTile(
                title: Text('Citizenship ID Image'),
                subtitle: Text(citizenshipPhoto != null ? 'Image Selected' : 'No image selected'),
                trailing: IconButton(icon: Icon(Icons.upload), onPressed: () => _pickImage('citizenship')),
              ),
              ListTile(
                title: Text('Driver Photo'),
                subtitle: Text(driverPhoto != null ? 'Image Selected' : 'No image selected'),
                trailing: IconButton(icon: Icon(Icons.upload), onPressed: () => _pickImage('driver')),
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _submitForm, child: Text('Submit Verification')),
            ],
          ),
        ),
      ),
    );
  }
}
