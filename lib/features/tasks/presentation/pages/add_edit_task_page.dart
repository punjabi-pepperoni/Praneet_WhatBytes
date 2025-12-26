import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_auth_app/core/widgets/gradient_background.dart';
import 'package:flutter_auth_app/features/tasks/domain/entities/task_entity.dart';
import 'package:flutter_auth_app/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:flutter_auth_app/features/tasks/presentation/bloc/task_event.dart';
import 'package:flutter_auth_app/features/tasks/presentation/bloc/task_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddEditTaskPage extends StatefulWidget {
  final TaskEntity? task;

  const AddEditTaskPage({super.key, this.task});

  @override
  State<AddEditTaskPage> createState() => _AddEditTaskPageState();
}

class _AddEditTaskPageState extends State<AddEditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late TaskPriority _priority;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.task?.description ?? '');
    _selectedDate = widget.task?.dueDate ?? DateTime.now();
    _priority = widget.task?.priority ?? TaskPriority.medium;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final task = TaskEntity(
        id: widget.task?.id ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: _selectedDate,
        priority: _priority,
        isCompleted: widget.task?.isCompleted ?? false,
      );

      if (widget.task == null) {
        context.read<TaskBloc>().add(AddTaskRequested(task, userId));
      } else {
        context.read<TaskBloc>().add(EditTaskRequested(task, userId));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskBloc, TaskState>(
      listenWhen: (previous, current) =>
          previous.lastSuccessTimestamp != current.lastSuccessTimestamp ||
          previous.status != current.status,
      listener: (context, state) {
        if (state.status == TaskStatus.success &&
            state.lastSuccessTimestamp != null) {
          Navigator.pop(context);
        }
        if (state.status == TaskStatus.error && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.redAccent,
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        body: GradientBackground(
          showBlobs: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField('Title', _titleController),
                  const SizedBox(height: 20),
                  _buildTextField('Description', _descriptionController,
                      maxLines: 3),
                  const SizedBox(height: 20),
                  _buildDatePicker(context),
                  const SizedBox(height: 20),
                  _buildPriorityPicker(),
                  const SizedBox(height: 40),
                  BlocBuilder<TaskBloc, TaskState>(
                    builder: (context, state) {
                      final isSubmitting =
                          state.status == TaskStatus.submitting;
                      return SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: isSubmitting ? null : _saveTask,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                          ),
                          child: isSubmitting
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text('Save Task',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white)),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 16)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            fillColor: Colors.white.withValues(alpha: 0.1),
            filled: true,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? 'Please enter $label' : null,
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Due Date',
            style: TextStyle(color: Colors.white70, fontSize: 16)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) setState(() => _selectedDate = date);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('dd/MM/yyyy').format(_selectedDate),
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
                const Icon(Icons.calendar_today, color: Colors.white70),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Priority',
            style: TextStyle(color: Colors.white70, fontSize: 16)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: TaskPriority.values.map((p) {
            final isSelected = _priority == p;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ChoiceChip(
                  label: Text(p.name.toUpperCase()),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _priority = p);
                  },
                  selectedColor: Colors.blueAccent,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
