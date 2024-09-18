class UserModel {
  String firstName;
  String lastName;
  String email;
  String password;
  String phoneNumber;
  String passwordConfirmation; // Add this line

  UserModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.phoneNumber,
    this.passwordConfirmation = '', // Initialize if needed
  });
}
