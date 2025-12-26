import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthUser>> loginWithEmail(String email, String password);
  Future<Either<Failure, AuthUser>> signUpWithEmail(String email, String password);
  Future<Either<Failure, AuthUser>> signInWithGoogle();
  Future<Either<Failure, AuthUser>> signInWithFacebook();
  Future<Either<Failure, AuthUser>> signInWithApple();
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, AuthUser>> getCurrentUser();
}
