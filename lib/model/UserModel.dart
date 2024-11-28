class UserModel {
  String firstName;
  String lastName;
  String email;
  String password;
  String phoneNumber;
  String passwordConfirmation; // Add this line
  String token; // Add token field

  UserModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.phoneNumber,
    this.passwordConfirmation = '', // Initialize if needed
    this.token = '', // Initialize token with an empty string (or you can assign a default token if available)
  });
}



// class User {
//   final String firstName;
//   final String lastName;
//   final String email;
//   final String phoneNumber;
//   final bool isAdmin; // Ensure this is a bool

//   User({
//     required this.firstName,
//     required this.lastName,
//     required this.email,
//     required this.phoneNumber,
//     required this.isAdmin,
//   });

//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       firstName: json['firstName'] ?? '',
//       lastName: json['lastName'] ?? '',
//       email: json['email'] ?? '',
//       phoneNumber: json['phoneNumber'] ?? '',
//       isAdmin: json['isAdmin'] ?? false, // Ensure this is a bool
//     );
//   }
// }

class User {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final bool isAdmin; 
  final String token; // Add token field

  User({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.isAdmin,
    required this.token, // Include token in the constructor
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      isAdmin: json['isAdmin'] ?? false,
      token: json['token'] ?? '', // Parse the token
    );
  }
}
