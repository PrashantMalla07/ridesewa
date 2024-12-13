class Driver {
  final int? id;
  final int? uid;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String photoUrl;  // Add photoUrl to the model
  

  Driver({
    required this.id,
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.photoUrl,  // Add photoUrl to constructor
    
  });

  // Adjust your fromJson method to safely handle nullable fields
  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] ?? 0,
      uid: json['uid'] is String ? int.tryParse(json['uid']) : json['uid'], 
      firstName: json['firstName'] ?? 'Unknown',
      lastName: json['lastName'] ?? 'Unknown',
      email: json['email'] ?? 'No email',
      phoneNumber: json['phoneNumber'] ?? 'No phone number',
      photoUrl: json['photoUrl'] ?? '',  // Ensure photoUrl is handled correctly
       // This could be null, ensure the field is handled correctly
    );
  }

  String get name => '$firstName $lastName';
}
