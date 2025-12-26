import 'package:equatable/equatable.dart';
import '../../domain/entities/task_entity.dart';

enum TaskStatus { initial, loading, submitting, success, error }

class TaskState extends Equatable {
  final List<TaskEntity> tasks;
  final TaskStatus status;
  final String? errorMessage;
  final DateTime? lastSuccessTimestamp;

  const TaskState({
    this.tasks = const [],
    this.status = TaskStatus.initial,
    this.errorMessage,
    this.lastSuccessTimestamp,
  });

  TaskState copyWith({
    List<TaskEntity>? tasks,
    TaskStatus? status,
    String? errorMessage,
    DateTime? lastSuccessTimestamp,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      lastSuccessTimestamp: lastSuccessTimestamp ?? this.lastSuccessTimestamp,
    );
  }

  @override
  List<Object?> get props =>
      [tasks, status, errorMessage, lastSuccessTimestamp];
}
