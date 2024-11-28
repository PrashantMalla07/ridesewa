import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      final newPassword = _newPasswordController.text.trim();
      final confirmPassword = _confirmPasswordController.text.trim();

      // Debugging password values
      print('New Password: "$newPassword"');
      print('Confirm Password: "$confirmPassword"');

      if (newPassword == confirmPassword) {
        print('Passwords match!');
      } else {
        print('Passwords do NOT match!');
      }

      // Check if new password and confirm password match
      if (newPassword != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('New password and confirmation do not match')),
        );
        return;
      }

      try {
        final token = await _secureStorage.read(key: 'auth_token');

        final response = await _dio.post(
          'http://localhost:3000/change-password',
          data: {
            'currentPassword': _currentPasswordController.text.trim(),
            'newPassword': newPassword,
            'confirmPassword': confirmPassword,
          },
          options: Options(
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': token != null ? 'Bearer $token' : '',
            },
          ),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Password changed successfully')),
          );
          _clearFormFields();
          Navigator.pop(context);
        } else {
          final errorMessage = response.data['error'] ?? 'Failed to change password';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      } on DioError catch (dioError) {
        String errorMessage = 'An error occurred';
        if (dioError.response != null) {
          errorMessage = dioError.response!.data['error'] ?? 'Server error occurred';
        } else {
          errorMessage = 'Network error: ${dioError.message}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unknown error occurred: $e')),
        );
      }
    }
  }

  void _clearFormFields() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  Widget _buildPasswordField(
    String label,
    IconData icon,
    TextEditingController controller,
    FormFieldValidator<String> validator,
    bool isPasswordVisible,
    VoidCallback toggleVisibility,
  ) {
    return TextFormField(
      controller: controller,
      obscureText: !isPasswordVisible,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: IconButton(
          icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: toggleVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.blue),
        ),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Change Password')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              _buildPasswordField(
                'Current Password',
                Icons.lock,
                _currentPasswordController,
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
                _isCurrentPasswordVisible,
                () => setState(() => _isCurrentPasswordVisible = !_isCurrentPasswordVisible),
              ),
              SizedBox(height: 20),
              _buildPasswordField(
                'New Password',
                Icons.lock_outline,
                _newPasswordController,
                (value) {
                  if (value == null || value.isEmpty || value.length < 6) {
                    return 'New password must be at least 6 characters';
                  }
                  return null;
                },
                _isNewPasswordVisible,
                () => setState(() => _isNewPasswordVisible = !_isNewPasswordVisible),
              ),
              SizedBox(height: 20),
              _buildPasswordField(
                'Confirm Password',
                Icons.lock_outline,
                _confirmPasswordController,
                (value) {
                  final newPassword = _newPasswordController.text.trim();
                  final confirmPassword = value!.trim();
                  print('Validator - New Password: "$newPassword"');
                  print('Validator - Confirm Password: "$confirmPassword"');
                  
                  if (confirmPassword.isEmpty) {
                    return 'Please confirm your new password';
                  }
                  if (newPassword != confirmPassword) {
                    return 'Passwords do not match!';
                  }
                  return null;
                },
                _isConfirmPasswordVisible,
                () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _changePassword,
                child: Text('Change Password'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF001A72), // Button color
                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
