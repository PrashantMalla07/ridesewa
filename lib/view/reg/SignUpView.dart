import 'package:flutter/material.dart';
import 'package:ridesewa/controller/SignUpController.dart'; 

class SignUpView extends StatefulWidget {
  @override
  _SignUpViewState createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final SignUpController controller = SignUpController();

  // Password visibility state for password and confirm password
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sign up',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 30),
              // First Name
              _buildTextField(
                'First Name',
                Icons.person_outline,
                (value) => controller.user.firstName = value!,
                controller.validateName,
              ),
              SizedBox(height: 20),
              // Last Name
              _buildTextField(
                'Last Name',
                Icons.person_outline,
                (value) => controller.user.lastName = value!,
                controller.validateName,
              ),
              SizedBox(height: 20),
              // Phone Number
              _buildTextField(
                'Phone Number',
                Icons.phone_outlined,
                (value) => controller.user.phoneNumber = value!,
                controller.validatePhoneNumber,
              ),
              SizedBox(height: 20),
              // Email
              _buildTextField(
                'Email address',
                Icons.email_outlined,
                (value) => controller.user.email = value!,
                controller.validateEmail,
              ),
              SizedBox(height: 20),
              // Password Field
              _buildPasswordField(
                'Password',
                Icons.lock_outline,
                (value) => controller.user.password = value!,
                controller.validatePassword,
                _isPasswordVisible,
                () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
              SizedBox(height: 20),
              // Confirm Password Field
              _buildPasswordField(
                'Confirm Password',
                Icons.lock_outline,
                (value) {
                  if (value != controller.user.password) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                controller.validatePassword,
                _isConfirmPasswordVisible,
                () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
              ),
              SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    controller.submitForm(context);
                  },
                  child: Text('Sign Up'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF001A72),
                    padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () {
                    // Navigate to login screen
                    Navigator.pushNamed(context, '/login');
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "Already have an account? ",
                      style: TextStyle(color: Colors.grey),
                      children: [
                        TextSpan(
                          text: "Login",
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to build general text fields
  Widget _buildTextField(String hintText, IconData icon, Function(String?) onSaved, String? Function(String?)? validator) {
    return TextFormField(
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hintText,
        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.blue),
        ),
      ),
      onSaved: onSaved,
      validator: validator,
    );
  }

  // Method to build password fields
  Widget _buildPasswordField(
    String hintText,
    IconData icon,
    Function(String?) onSaved,
    String? Function(String?)? validator,
    bool isPasswordVisible,
    VoidCallback toggleVisibility,
  ) {
    return TextFormField(
      obscureText: !isPasswordVisible,  // Toggle based on visibility state
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: toggleVisibility,
        ),
        hintText: hintText,
        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.blue),
        ),
      ),
      onSaved: onSaved,
      validator: validator,
    );
  }
}
