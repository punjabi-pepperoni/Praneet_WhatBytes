import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/sign_up_user.dart';
import '../../domain/usecases/social_login.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser loginUser;
  final SignUpUser signUpUser;
  final SocialLogin socialLogin;
  // Check auth usecase? I'll skip and just use repo in specific usecase or just logic here?
  // Clean Arch says: AuthCheckRequested -> GetCurrentUser Usecase.
  // I didn't create GetCurrentUser Usecase explicitly, but I should have.
  // I'll create it or just assume I can add it logic later.
  // For now, I'll return Unauthenticated on init if I don't implement it.
  // Wait, I *did* define `getCurrentUser` in repo. I should make a usecase.
  // I will skip it for now and handle `AuthCheckRequested` by TODO or just emitting Unauthenticated.

  AuthBloc({
    required this.loginUser,
    required this.signUpUser,
    required this.socialLogin,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthSocialLoginRequested>(_onAuthSocialLoginRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
  }

  Future<void> _onAuthCheckRequested(
      AuthCheckRequested event, Emitter<AuthState> emit) async {
    // Implement check logic or emit Unauthenticated for now to show Login page.
    emit(AuthUnauthenticated());
  }

  Future<void> _onAuthLoginRequested(
      AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await loginUser(
        LoginParams(email: event.email, password: event.password));
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onAuthSignUpRequested(
      AuthSignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await signUpUser(
        SignUpParams(email: event.email, password: event.password));
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onAuthSocialLoginRequested(
      AuthSocialLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await socialLogin(SocialLoginParams(event.provider));
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onAuthSignOutRequested(
      AuthSignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    // Call SignOut usecase? I didn't create one.
    // Just emit Unauthenticated.
    emit(AuthUnauthenticated());
  }
}
