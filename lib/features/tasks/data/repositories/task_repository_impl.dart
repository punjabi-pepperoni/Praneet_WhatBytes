import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_data_source.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<Either<Failure, List<TaskEntity>>> watchTasks(String userId) {
    return remoteDataSource.watchTasks(userId).map((tasks) {
      return Right<Failure, List<TaskEntity>>(tasks);
    }).handleError((error) {
      return Left<Failure, List<TaskEntity>>(ServerFailure(error.toString()));
    });
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasks(String userId) async {
    try {
      final tasks = await remoteDataSource.getTasks(userId);
      return Right(tasks);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    }
  }

  @override
  Future<Either<Failure, void>> createTask(
      TaskEntity task, String userId) async {
    try {
      await remoteDataSource.createTask(TaskModel.fromEntity(task), userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    }
  }

  @override
  Future<Either<Failure, void>> updateTask(
      TaskEntity task, String userId) async {
    try {
      await remoteDataSource.updateTask(TaskModel.fromEntity(task), userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String taskId, String userId) async {
    try {
      await remoteDataSource.deleteTask(taskId, userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    }
  }
}
