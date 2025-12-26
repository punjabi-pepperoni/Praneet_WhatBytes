import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class UpdateTask implements UseCase<void, UpdateTaskParams> {
  final TaskRepository repository;

  UpdateTask(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateTaskParams params) async {
    return await repository.updateTask(params.task, params.userId);
  }
}

class UpdateTaskParams extends Equatable {
  final TaskEntity task;
  final String userId;

  const UpdateTaskParams({required this.task, required this.userId});

  @override
  List<Object?> get props => [task, userId];
}
