class UserModel {
  final int id;
  final String uuid;
  final String email;
  final String password;
  final String? avatar;
  final String firstName;
  final String lastName;
  final bool emailVerified;
  final bool isActive;
  final String? phone;
  final int roleId;
  // Add other fields as needed

  UserModel({
    required this.id,
    required this.uuid,
    required this.email,
    required this.password,
    this.avatar,
    required this.firstName,
    required this.lastName,
    required this.emailVerified,
    required this.isActive,
    this.phone,
    required this.roleId,
    // Initialize other fields
  });

  // Create an "empty" factory constructor
  factory UserModel.empty() {
    return UserModel(
      id: 0,
      uuid: '',
      email: '',
      password: '',
      avatar: null,
      firstName: '',
      lastName: '',
      emailVerified: false,
      isActive: false,
      phone: null,
      roleId: 0,
    );
  }

  // Create a factory method to create an instance from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0, // Use null-aware operators
      uuid: json['uuid'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      avatar: json['avatar'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      emailVerified: json['email_verified'] ?? false,
      isActive: json['is_active'] ?? false,
      phone: json['phone'],
      roleId: json['role_id'] ?? 0,
    );
  }
}
