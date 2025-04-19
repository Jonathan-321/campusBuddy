import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart' as app_user;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final app_user.User user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class PasswordResetSent extends AuthState {
  const PasswordResetSent();
}

class SignUpSuccess extends AuthState {}

class SignInSuccess extends AuthState {}
