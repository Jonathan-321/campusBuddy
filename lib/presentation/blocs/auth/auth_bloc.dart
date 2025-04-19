import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/auth_usecase.dart';
import '../../../domain/entities/user.dart' as app_user;
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthUseCase _authUseCase;

  AuthBloc(this._authUseCase) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<ResetAuthState>(_onResetAuthState);
  }

  // Factory constructor for easier initialization
  factory AuthBloc.create() {
    return AuthBloc(AuthUseCase());
  }

  void _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authUseCase.getCurrentUser();
      if (user.isAuthenticated) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      print('Attempting to sign in user: ${event.email}');
      final user = await _authUseCase.signIn(
        email: event.email,
        password: event.password,
      );
      print('Sign in successful for user: ${user.email}');
      emit(SignInSuccess());
      emit(Authenticated(user));
    } catch (e) {
      print('Sign in error: $e');
      emit(AuthError(e.toString()));
    }
  }

  void _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      print('Attempting to sign up user: ${event.email}');
      final user = await _authUseCase.signUp(
        email: event.email,
        password: event.password,
        name: event.name,
      );
      print('Sign up successful for user: ${user.email}');
      emit(SignUpSuccess());
      emit(Authenticated(user));
    } catch (e) {
      print('Sign up error: $e');
      emit(AuthError(e.toString()));
    }
  }

  void _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authUseCase.signOut();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onResetAuthState(
    ResetAuthState event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthInitial());
  }
}
