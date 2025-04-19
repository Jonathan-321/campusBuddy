import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final bool isAuthenticated;

  const User({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    this.isAuthenticated = false,
  });

  const User.empty()
      : id = '',
        email = '',
        name = null,
        photoUrl = null,
        isAuthenticated = false;

  @override
  List<Object?> get props => [id, email, name, photoUrl, isAuthenticated];

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    bool? isAuthenticated,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}
