import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/task_entity.dart';

abstract class TaskRepository {
  Stream<Either<Failure, List<TaskEntity>>> watchTasks(String userId);
  Future<Either<Failure, List<TaskEntity>>> getTasks(String userId);
  Future<Either<Failure, void>> createTask(TaskEntity task, String userId);
  Future<Either<Failure, void>> updateTask(TaskEntity task, String userId);
  Future<Either<Failure, void>> deleteTask(String taskId, String userId);
}
