import 'package:equatable/equatable.dart';
import '../../domain/usecases/social_login.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthSignUpRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class AuthSocialLoginRequested extends AuthEvent {
  final SocialProvider provider;
  const AuthSocialLoginRequested(this.provider);

  @override
  List<Object> get props => [provider];
}

class AuthSignOutRequested extends AuthEvent {}
