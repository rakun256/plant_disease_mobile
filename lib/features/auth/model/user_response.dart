class UserResponse {
  UserResponse({
    required this.id,
    required this.email,
    this.fullName,
    required this.isActive,
  });

  final int id;
  final String email;
  final String? fullName;
  final bool isActive;

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String?,
      isActive: json['is_active'] as bool? ?? false,
    );
  }
}
