class SignUpRequestModel {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String role;
  final String? phoneNumber;
  final String? dateOfBirth;

  SignUpRequestModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.role,
    this.phoneNumber,
    this.dateOfBirth,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'role': role,
    };

    // Add optional fields only if they are not null
    if (phoneNumber != null && phoneNumber!.isNotEmpty) {
      data['phoneNumber'] = phoneNumber;
    }
    if (dateOfBirth != null && dateOfBirth!.isNotEmpty) {
      data['dateOfBirth'] = dateOfBirth;
    }

    return data;
  }
}
