import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignUpUser implements UseCase<AuthUser, SignUpParams> {
  final AuthRepository repository;
  SignUpUser(this.repository);

  @override
  Future<Either<Failure, AuthUser>> call(SignUpParams params) async {
    return await repository.signUpWithEmail(params.email, params.password);
  }
}

class SignUpParams extends Equatable {
  final String email;
  final String password;
  const SignUpParams({required this.email, required this.password});
  @override
  List<Object> get props => [email, password];
}
