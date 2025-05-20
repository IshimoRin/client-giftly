import 'user_role.dart';

class User {
  final String id;
  final String? name;
  final String? email;
  final String? photoUrl;
  final UserRole role;
  final String? phone;
  final DateTime? birthDate;

  const User({
    required this.id,
    this.name,
    this.email,
    this.photoUrl,
    required this.role,
    this.phone,
    this.birthDate,
  });

  // Создаем объект из JSON
  factory User.fromJson(Map<String, dynamic> json) {
    print('Received JSON data: $json'); // Debug print

    String? fullName;
    if (json['first_name'] != null || json['last_name'] != null) {
      final firstName = json['first_name'] ?? '';
      final lastName = json['last_name'] ?? '';
      fullName = [firstName, lastName].where((s) => s.isNotEmpty).join(' ');
      print('Parsed name: firstName=$firstName, lastName=$lastName, fullName=$fullName'); // Debug print
    }

    final user = User(
      id: json['id'].toString(),
      name: fullName,
      email: json['email'],
      photoUrl: json['photo_url'],
      role: UserRole.values.firstWhere(
        (role) => role.toString().split('.').last == json['role'],
        orElse: () => UserRole.customer,
      ),
      phone: json['phone'],
      birthDate: json['birth_date'] != null ? DateTime.parse(json['birth_date']) : null,
    );
    print('Created user: ${user.toJson()}'); // Debug print
    return user;
  }

  // Преобразуем объект в JSON
  Map<String, dynamic> toJson() {
    final nameParts = name?.split(' ') ?? [];
    final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'photo_url': photoUrl,
      'role': role.toString().split('.').last,
      'phone': phone,
      'birth_date': birthDate?.toIso8601String(),
    };
  }

  // Создаем копию пользователя с новыми данными
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    UserRole? role,
    String? phone,
    DateTime? birthDate,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
    );
  }

  // Преобразование строки в UserRole
  static UserRole _roleFromString(String role) {
    switch (role.toLowerCase()) {
      case 'buyer':
        return UserRole.customer;
      case 'seller':
        return UserRole.seller;
      default:
        return UserRole.guest;
    }
  }
} 