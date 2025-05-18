import 'user_role.dart';

class User {
  final String id;
  final String? name;
  final String? email;
  final String? photoUrl;
  final UserRole role;

  const User({
    required this.id,
    this.name,
    this.email,
    this.photoUrl,
    required this.role,
  });

  // Создаем объект из JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      photoUrl: json['photoUrl'] as String?,
      role: _roleFromString(json['role'] as String? ?? 'guest'),
    );
  }

  // Преобразуем объект в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'role': role.toString().split('.').last,
    };
  }

  // Создаем копию пользователя с новыми данными
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    UserRole? role,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
    );
  }

  // Преобразование строки в UserRole
  static UserRole _roleFromString(String role) {
    switch (role.toLowerCase()) {
      case 'customer':
        return UserRole.customer;
      case 'seller':
        return UserRole.seller;
      default:
        return UserRole.guest;
    }
  }
} 