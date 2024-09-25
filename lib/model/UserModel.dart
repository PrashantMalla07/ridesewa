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


class User {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final bool isAdmin; // Ensure this is a bool

  User({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.isAdmin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      isAdmin: json['isAdmin'] ?? false, // Ensure this is a bool
    );
  }
}
