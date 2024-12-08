import 'package:flutter/material.dart';
import 'package:ridesewa/controller/SignUpController.dart';



class SignUpView extends StatefulWidget {
  @override
  _SignUpViewState createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final SignUpController _controller = SignUpController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 30),

              // First Name Field
              _buildTextField(
                labelText: 'First Name',
                icon: Icons.person_outline,
                onSaved: (value) => _controller.user.firstName = value!,
                validator: _controller.validateName,
              ),
              SizedBox(height: 20),

              // Last Name Field
              _buildTextField(
                labelText: 'Last Name',
                icon: Icons.person_outline,
                onSaved: (value) => _controller.user.lastName = value!,
                validator: _controller.validateName,
              ),
              SizedBox(height: 20),

              // Email Field
              _buildTextField(
                labelText: 'Email Address',
                icon: Icons.email_outlined,
                onSaved: (value) => _controller.user.email = value!,
                validator: _controller.validateEmail,
              ),
              SizedBox(height: 20),

              // Phone Number Field
              _buildTextField(
                labelText: 'Phone Number',
                icon: Icons.phone,
                onSaved: (value) => _controller.user.phoneNumber = value!,
                validator: _controller.validatePhoneNumber,
              ),
              SizedBox(height: 20),

              // Password Field
              _buildPasswordField(
                labelText: 'Password',
                onSaved: (value) => _controller.user.password = value!,
                validator: _controller.validatePassword,
              ),
              SizedBox(height: 40),

              // Sign Up Button
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    // Call the controller's submitForm method
                    await _controller.submitForm(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF001A72), // Button color
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 120),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Login Option
              Center(
                child: GestureDetector(
                  onTap: () {
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

  // Build Text Field Method
  Widget _buildTextField({
    required String labelText,
    required IconData icon,
    required Function(String?) onSaved,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.grey),
        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
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

  // Build Password Field Method
  Widget _buildPasswordField({
    required String labelText,
    required Function(String?) onSaved,
    required String? Function(String?) validator,
  }) {
    bool isPasswordVisible = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return TextFormField(
          obscureText: !isPasswordVisible,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock_outline),
            labelText: labelText,
            labelStyle: TextStyle(color: Colors.grey),
            contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            suffixIcon: IconButton(
              icon: Icon(isPasswordVisible
                  ? Icons.visibility
                  : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  isPasswordVisible = !isPasswordVisible;
                });
              },
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
          onSaved: onSaved,
          validator: validator,
        );
      },
    );
  }
}
