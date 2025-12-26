import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

enum SocialProvider { google, facebook, apple }

class SocialLogin implements UseCase<AuthUser, SocialLoginParams> {
  final AuthRepository repository;
  SocialLogin(this.repository);

  @override
  Future<Either<Failure, AuthUser>> call(SocialLoginParams params) async {
    switch (params.provider) {
      case SocialProvider.google:
        return await repository.signInWithGoogle();
      case SocialProvider.facebook:
        return await repository.signInWithFacebook();
      case SocialProvider.apple:
        return await repository.signInWithApple();
    }
  }
}

class SocialLoginParams extends Equatable {
  final SocialProvider provider;
  const SocialLoginParams(this.provider);
  @override
  List<Object> get props => [provider];
}
