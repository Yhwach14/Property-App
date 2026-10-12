import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role; // 'ADMIN' or 'OWNER'

  const AuthUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id'] as String,
    email: json['email'] as String,
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String,
    role: json['role'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'role': role,
  };

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [id, email, firstName, lastName, role];
}
