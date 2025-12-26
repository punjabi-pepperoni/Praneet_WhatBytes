import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/update_task.dart';
import '../../domain/usecases/watch_tasks.dart';
import 'task_event.dart';
import 'task_state.dart';
import 'dart:async';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasks getTasks;
  final WatchTasks watchTasks;
  final CreateTask createTask;
  final UpdateTask updateTask;
  final DeleteTask deleteTask;
  StreamSubscription? _taskSubscription;

  TaskBloc({
    required this.getTasks,
    required this.watchTasks,
    required this.createTask,
    required this.updateTask,
    required this.deleteTask,
  }) : super(const TaskState()) {
    on<LoadTasksRequested>(_onLoadTasks);
    on<AddTaskRequested>(_onAddTask);
    on<EditTaskRequested>(_onEditTask);
    on<RemoveTaskRequested>(_onRemoveTask);
    on<ToggleTaskCompletionRequested>(_onToggleTaskCompletion);
    on<OnTasksUpdated>(_onTasksUpdated);
    on<OnTaskError>(_onTaskError);
  }

  @override
  Future<void> close() {
    _taskSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadTasks(
    LoadTasksRequested event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(status: TaskStatus.loading));
    await _taskSubscription?.cancel();
    _taskSubscription = watchTasks(event.userId).listen(
      (result) {
        result.fold(
          (failure) => add(OnTaskError(failure.message)),
          (tasks) => add(OnTasksUpdated(tasks)),
        );
      },
    );
  }

  void _onTasksUpdated(OnTasksUpdated event, Emitter<TaskState> emit) {
    emit(state.copyWith(status: TaskStatus.success, tasks: event.tasks));
  }

  void _onTaskError(OnTaskError event, Emitter<TaskState> emit) {
    emit(state.copyWith(status: TaskStatus.error, errorMessage: event.message));
  }

  Future<void> _onAddTask(
    AddTaskRequested event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(status: TaskStatus.submitting));
    final result = await createTask(
      CreateTaskParams(task: event.task, userId: event.userId),
    );
    result.fold(
      (failure) => emit(state.copyWith(
          status: TaskStatus.error, errorMessage: failure.message)),
      (_) => emit(state.copyWith(
          status: TaskStatus.success, lastSuccessTimestamp: DateTime.now())),
    );
  }

  Future<void> _onEditTask(
    EditTaskRequested event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(status: TaskStatus.submitting));
    final result = await updateTask(
      UpdateTaskParams(task: event.task, userId: event.userId),
    );
    result.fold(
      (failure) => emit(state.copyWith(
          status: TaskStatus.error, errorMessage: failure.message)),
      (_) => emit(state.copyWith(
          status: TaskStatus.success, lastSuccessTimestamp: DateTime.now())),
    );
  }

  Future<void> _onRemoveTask(
    RemoveTaskRequested event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(status: TaskStatus.submitting));
    final result = await deleteTask(
      DeleteTaskParams(taskId: event.taskId, userId: event.userId),
    );
    result.fold(
      (failure) => emit(state.copyWith(
          status: TaskStatus.error, errorMessage: failure.message)),
      (_) => emit(state.copyWith(
          status: TaskStatus.success, lastSuccessTimestamp: DateTime.now())),
    );
  }

  Future<void> _onToggleTaskCompletion(
    ToggleTaskCompletionRequested event,
    Emitter<TaskState> emit,
  ) async {
    final updatedTask = TaskEntity(
      id: event.task.id,
      title: event.task.title,
      description: event.task.description,
      dueDate: event.task.dueDate,
      priority: event.task.priority,
      isCompleted: !event.task.isCompleted,
    );
    await updateTask(
      UpdateTaskParams(task: updatedTask, userId: event.userId),
    );
  }
}
