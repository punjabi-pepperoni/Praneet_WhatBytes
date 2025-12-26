import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Stream<List<TaskModel>> watchTasks(String userId);
  Future<List<TaskModel>> getTasks(String userId);
  Future<void> createTask(TaskModel task, String userId);
  Future<void> updateTask(TaskModel task, String userId);
  Future<void> deleteTask(String taskId, String userId);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final FirebaseFirestore firestore;

  TaskRemoteDataSourceImpl({required this.firestore});

  @override
  Stream<List<TaskModel>> watchTasks(String userId) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TaskModel.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Future<List<TaskModel>> getTasks(String userId) async {
    try {
      final snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .orderBy('dueDate', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => TaskModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> createTask(TaskModel task, String userId) async {
    try {
      // Non-blocking call for optimistic UI and instant navigation
      firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .add(task.toJson());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateTask(TaskModel task, String userId) async {
    try {
      firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(task.id)
          .update(task.toJson());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteTask(String taskId, String userId) async {
    try {
      firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(taskId)
          .delete();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
