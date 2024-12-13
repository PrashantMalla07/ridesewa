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





class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final bool isAdmin; 
  final String token;
  final int uid; // Add token field

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.isAdmin,
    required this.token,
    required this.uid, // Include token in the constructor
  });

factory User.fromJson(Map<String, dynamic> json) {
  print('Parsing User: $json');  // Log the entire JSON response
  print('ID: ${json['id']}');  // Debug the ID value directly
  return User(
    id: json['userid'] ?? 0,
    firstName: json['firstName'] ?? '',
    lastName: json['lastName'] ?? '',
    email: json['email'] ?? '',
    phoneNumber: json['phoneNumber'] ?? '',
    isAdmin: json['isAdmin'] ?? false,
    token: json['token'] ?? '',
    uid: json['uid'] ?? 0,
  );
}


}
