import 'package:equatable/equatable.dart';
import '../../domain/entities/task_entity.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasksRequested extends TaskEvent {
  final String userId;

  const LoadTasksRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AddTaskRequested extends TaskEvent {
  final TaskEntity task;
  final String userId;

  const AddTaskRequested(this.task, this.userId);

  @override
  List<Object?> get props => [task, userId];
}

class EditTaskRequested extends TaskEvent {
  final TaskEntity task;
  final String userId;

  const EditTaskRequested(this.task, this.userId);

  @override
  List<Object?> get props => [task, userId];
}

class RemoveTaskRequested extends TaskEvent {
  final String taskId;
  final String userId;

  const RemoveTaskRequested(this.taskId, this.userId);

  @override
  List<Object?> get props => [taskId, userId];
}

class ToggleTaskCompletionRequested extends TaskEvent {
  final TaskEntity task;
  final String userId;

  const ToggleTaskCompletionRequested(this.task, this.userId);

  @override
  List<Object?> get props => [task, userId];
}

class OnTasksUpdated extends TaskEvent {
  final List<TaskEntity> tasks;
  const OnTasksUpdated(this.tasks);

  @override
  List<Object?> get props => [tasks];
}

class OnTaskError extends TaskEvent {
  final String message;
  const OnTaskError(this.message);

  @override
  List<Object?> get props => [message];
}
