class UserCreateRequest {
  UserCreateRequest({
    required this.email,
    required this.password,
    this.fullName,
  });

  final String email;
  final String password;
  final String? fullName;

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password, 'full_name': fullName};
  }
}
