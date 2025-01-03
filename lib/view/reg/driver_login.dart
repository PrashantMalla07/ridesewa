import 'package:flutter/material.dart';
import 'package:ridesewa/controller/driver_login_controller.dart';
import 'package:ridesewa/view/introScreen/selecton.dart';

class DriverLogin extends StatefulWidget {
  @override
  _DriverLoginState createState() => _DriverLoginState();
}

class _DriverLoginState extends State<DriverLogin> {
  final DriverLoginController controller = DriverLoginController();

  // Password visibility state for password
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
       
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo at the top
                Center(
                  child: Image.asset(
                    'assets/logo.png', // Make sure to place the logo.png in the assets folder
                    height: 150, // Adjust size as needed
                  ),
                ),
               
                Text(
                  'Welcome!',
                  style: TextStyle(
                    fontSize: screenWidth * 0.08, // Responsive font size
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Login to your account',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045, // Responsive font size
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 40),
                // Username or Phone Numbers
                _buildTextField(
                  'Username',
                  Icons.person_outline,
                  (value) => controller.identifier = value!,
                  controller.validateIdentifier,
                ),
                SizedBox(height: 20),
                // Password Field
                _buildPasswordField(
                  'Password',
                  Icons.lock_outline,
                  (value) => controller.password = value!,
                  controller.validatePassword,
                  _isPasswordVisible,
                  () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
                SizedBox(height: 30),
                // Login Button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      controller.driverSubmitForm(context);
                    },
                    child: Text('Login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF001A72),
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.25, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // Forgot Password
                TextButton(
                  onPressed: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SelectionScreen()),
                  );
                  },
                  child: Text(
                    'Go to Driver Or Passenger Page?',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                SizedBox(height: 20),
                // Sign up link
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/driverSignup'); // Navigate to sign up screen
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(color: Colors.grey),
                      children: [
                        TextSpan(
                          text: "Sign Up",
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Method to build general text fields
  Widget _buildTextField(String hintText, IconData icon, Function(String?) onSaved, String? Function(String?)? validator) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05), // 5% padding on both sides
      child: TextFormField(
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
      ),
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05), // 5% padding on both sides
      child: TextFormField(
        obscureText: !isPasswordVisible, // Toggle based on visibility state
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
      ),
    );
  }
}
