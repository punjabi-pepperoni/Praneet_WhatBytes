import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/task_repository.dart';

class DeleteTask implements UseCase<void, DeleteTaskParams> {
  final TaskRepository repository;

  DeleteTask(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteTaskParams params) async {
    return await repository.deleteTask(params.taskId, params.userId);
  }
}

class DeleteTaskParams extends Equatable {
  final String taskId;
  final String userId;

  const DeleteTaskParams({required this.taskId, required this.userId});

  @override
  List<Object?> get props => [taskId, userId];
}
