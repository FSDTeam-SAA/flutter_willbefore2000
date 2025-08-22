class SignupRequest {
  final String name;
  final String email;
  final String password;
  final String? phoneNumber;
  final String? fcmToken;

  SignupRequest({
    required this.name,
    required this.email,
    required this.password,
    this.phoneNumber,
    this.fcmToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
      'fcmToken': fcmToken,
    };
  }
}
