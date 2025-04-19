import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required String id,
    required String email,
    String? name,
    String? photoUrl,
    bool isAuthenticated = false,
  }) : super(
          id: id,
          email: email,
          name: name,
          photoUrl: photoUrl,
          isAuthenticated: isAuthenticated,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      photoUrl: json['photoUrl'],
      isAuthenticated: json['isAuthenticated'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'isAuthenticated': isAuthenticated,
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      photoUrl: user.photoUrl,
      isAuthenticated: user.isAuthenticated,
    );
  }

  static UserModel empty() {
    return UserModel(
      id: '',
      email: '',
      name: null,
      photoUrl: null,
      isAuthenticated: false,
    );
  }
}
