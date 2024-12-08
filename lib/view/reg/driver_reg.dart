import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class DriverRegisterScreen extends StatefulWidget {
  @override
  _DriverRegisterScreenState createState() => _DriverRegisterScreenState();
}

class _DriverRegisterScreenState extends State<DriverRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  bool showVerificationDetails = false;

  // Basic Registration Fields
  String? firstName, lastName, email, phoneNumber, password;

  // Driver Verification Fields
  String? licenseNumber, citizenshipId, vehicleType, vehicleColor, vehicleNumber;
  File? licensePhoto, citizenshipPhoto, driverPhoto;

  // List of vehicle types for the dropdown
  List<String> vehicleTypes = ['Car', 'Bike', 'Scooter'];
  
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

  // Submit Form to Register Driver
  Future<void> _submitForm() async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();

    // Debugging: Check if firstName is set correctly
    print("First Name: $firstName");
    
    // Prepare the registration and verification data
    final uri = Uri.parse('http://localhost:3000/api/driver-register');
    final request = http.MultipartRequest('POST', uri)
      ..fields['firstName'] = firstName ?? ''
      ..fields['lastName'] = lastName ?? ''
      ..fields['email'] = email ?? ''
      ..fields['phoneNumber'] = phoneNumber ?? ''
      ..fields['password'] = password ?? ''
      ..fields['licenseNumber'] = licenseNumber ?? ''
      ..fields['citizenshipId'] = citizenshipId ?? ''
      ..fields['vehicleType'] = vehicleType ?? ''
      ..fields['vehicleColor'] = vehicleColor ?? ''
      ..fields['vehicleNumber'] = vehicleNumber ?? '';

    // Add images if available
    if (licensePhoto != null) {
      request.files.add(await http.MultipartFile.fromPath('licensePhoto', licensePhoto!.path));
    }
    if (citizenshipPhoto != null) {
      request.files.add(await http.MultipartFile.fromPath('citizenshipPhoto', citizenshipPhoto!.path));
    }
    if (driverPhoto != null) {
      request.files.add(await http.MultipartFile.fromPath('driverPhoto', driverPhoto!.path));
    }

    try {
      final response = await request.send();

      if (response.statusCode == 201) {
        // Successful registration
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Driver registered successfully!')));

        // Navigate to the Driver Login screen
        Navigator.pushReplacementNamed(context, '/driver_login');
      } else {
        // Handle registration error
        final responseBody = await response.stream.bytesToString();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration failed: $responseBody')));
      }
    } catch (e) {
      // Handle network or server errors
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }
}


  // Build TextField Method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Driver',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Registration',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildTextField(
                'First Name',
                Icons.person_outline,
                (value) => firstName = value,
                (value) => value == null || value.isEmpty ? 'Enter first name' : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                'Last Name',
                Icons.person_outline,
                (value) => lastName = value,
                (value) => value == null || value.isEmpty ? 'Enter last name' : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                'Email',
                Icons.email_outlined,
                (value) => email = value,
                (value) => value == null || value.isEmpty || !RegExp(r'\S+@\S+\.\S+').hasMatch(value)
                    ? 'Enter a valid email'
                    : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                'Phone Number',
                Icons.phone_outlined,
                (value) => phoneNumber = value,
                (value) => value == null || value.isEmpty || value.length < 10
                    ? 'Enter a valid phone number'
                    : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                'Password',
                Icons.lock_outline,
                (value) => password = value,
                (value) => value == null || value.isEmpty || value.length < 6
                    ? 'Password must be at least 6 characters'
                    : null,
              ),

              // Toggle Driver Verification Details
              SwitchListTile(
                title: const Text('Enter Driver Verification Details'),
                value: showVerificationDetails,
                onChanged: (val) => setState(() => showVerificationDetails = val),
              ),

              if (showVerificationDetails)
                Column(
                  children: [
                    _buildTextField(
                      'Driver\'s License Number',
                      Icons.credit_card,
                      (value) => licenseNumber = value,
                      (value) => value == null || value.isEmpty ? 'Enter license number' : null,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      'Citizenship ID',
                      Icons.document_scanner,
                      (value) => citizenshipId = value,
                      (value) => value == null || value.isEmpty ? 'Enter citizenship ID' : null,
                    ),
                    const SizedBox(height: 20),
                    // Vehicle Type Dropdown
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                      child: DropdownButtonFormField<String>(
                        value: vehicleType,
                        hint: const Text('Select Vehicle Type'),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.directions_car),
                          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                        ),
                        items: vehicleTypes.map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            vehicleType = value;
                          });
                        },
                        validator: (value) => value == null ? 'Select a vehicle type' : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      'Vehicle Color',
                      Icons.color_lens,
                      (value) => vehicleColor = value,
                      (value) => value == null || value.isEmpty ? 'Enter vehicle color' : null,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      'Vehicle Number',
                      Icons.confirmation_number,
                      (value) => vehicleNumber = value,
                      (value) => value == null || value.isEmpty ? 'Enter vehicle number' : null,
                    ),
                    const SizedBox(height: 20),
                    // Image upload buttons
                    ListTile(
                      title: const Text('Driver\'s License Image'),
                      subtitle: Text(licensePhoto != null ? 'Image Selected' : 'No image selected'),
                      trailing: IconButton(icon: const Icon(Icons.upload), onPressed: () => _pickImage('license')),
                    ),
                    const SizedBox(height: 20),
                    ListTile(
                      title: const Text('Citizenship ID Image'),
                      subtitle: Text(citizenshipPhoto != null ? 'Image Selected' : 'No image selected'),
                      trailing: IconButton(icon: const Icon(Icons.upload), onPressed: () => _pickImage('citizenship')),
                    ),
                    const SizedBox(height: 20),
                    ListTile(
                      title: const Text('Driver Photo'),
                      subtitle: Text(driverPhoto != null ? 'Image Selected' : 'No image selected'),
                      trailing: IconButton(icon: const Icon(Icons.upload), onPressed: () => _pickImage('driver')),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF001A72),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

   Widget _buildTextField(String hintText, IconData icon, Function(String?) onSaved, String? Function(String?)? validator) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05), // 5% padding on both sides
      child: TextFormField(
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hintText,
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.blue),
          ),
        ),
        onSaved: onSaved,
        validator: validator,
      ),
    );
  }
}
