import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, AuthUser>> loginWithEmail(
      String email, String password) async {
    try {
      final remoteUser = await remoteDataSource.loginWithEmail(email, password);
      await localDataSource.cacheUser(remoteUser);
      return Right(remoteUser);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server Error'));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> signUpWithEmail(
      String email, String password) async {
    try {
      final remoteUser =
          await remoteDataSource.signUpWithEmail(email, password);
      await localDataSource.cacheUser(remoteUser);
      return Right(remoteUser);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server Error'));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> signInWithGoogle() async {
    try {
      final remoteUser = await remoteDataSource.signInWithGoogle();
      await localDataSource.cacheUser(remoteUser);
      return Right(remoteUser);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Google Sign In Error'));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> signInWithFacebook() async {
    try {
      final remoteUser = await remoteDataSource.signInWithFacebook();
      await localDataSource.cacheUser(remoteUser);
      return Right(remoteUser);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Facebook Sign In Error'));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> signInWithApple() async {
    try {
      final remoteUser = await remoteDataSource.signInWithApple();
      await localDataSource.cacheUser(remoteUser);
      return Right(remoteUser);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Apple Sign In Error'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      await localDataSource.clearUser();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Sign Out Error'));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> getCurrentUser() async {
    try {
      // First check remote for session
      final remoteUser = await remoteDataSource.getCurrentUser();
      if (remoteUser != null) {
        await localDataSource.cacheUser(remoteUser);
        return Right(remoteUser);
      }
      // If no remote user, maybe check local?
      // Usually if not logged in remotely, token is invalid.
      // But for offline start, maybe local?
      // Let's rely on local if remote is null but we had a session?
      // For now, simple: try local if remote is null.
      try {
        final localUser = await localDataSource.getLastUser();
        return Right(localUser);
      } on CacheException {
        return const Left(CacheFailure('No user logged in'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server Error'));
    }
  }
}
