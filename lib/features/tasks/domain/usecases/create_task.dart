import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class CreateTask implements UseCase<void, CreateTaskParams> {
  final TaskRepository repository;

  CreateTask(this.repository);

  @override
  Future<Either<Failure, void>> call(CreateTaskParams params) async {
    return await repository.createTask(params.task, params.userId);
  }
}

class CreateTaskParams extends Equatable {
  final TaskEntity task;
  final String userId;

  const CreateTaskParams({required this.task, required this.userId});

  @override
  List<Object?> get props => [task, userId];
}
