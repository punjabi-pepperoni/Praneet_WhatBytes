import 'package:equatable/equatable.dart';

enum TaskPriority { low, medium, high }

class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskPriority priority;
  final bool isCompleted;

  const TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.isCompleted,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        dueDate,
        priority,
        isCompleted,
      ];
}
