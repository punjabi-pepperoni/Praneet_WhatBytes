import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_auth_app/features/tasks/domain/entities/task_entity.dart';
import 'package:flutter_auth_app/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:flutter_auth_app/features/tasks/presentation/bloc/task_event.dart';
import 'package:flutter_auth_app/features/tasks/presentation/bloc/task_state.dart';
import 'package:flutter_auth_app/features/tasks/presentation/pages/add_edit_task_page.dart';
import 'package:flutter_auth_app/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_auth_app/core/widgets/gradient_background.dart';
import 'package:flutter_auth_app/core/widgets/pressable_scale.dart';
import 'package:intl/intl.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  TaskPriority? _priorityFilter;
  bool? _statusFilter;
  int _selectedIndex = 0;

  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<TaskBloc>().add(LoadTasksRequested(user.uid));
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        showBlobs: false, // Less distracting background for tasks
        child: BlocListener<TaskBloc, TaskState>(
          listenWhen: (previous, current) =>
              previous.errorMessage != current.errorMessage &&
              current.errorMessage != null,
          listener: (context, state) {
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
          },
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _selectedIndex = index);
            },
            children: [
              _buildTasksView(),
              _buildStatsView(),
              _buildCalendarView(),
              _buildProfileView(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildCenterButton(),
    );
  }

  Widget _buildCenterButton() {
    return Container(
      width: 70, // Increased size by approx 25%
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF1E1B4B)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: PressableScale(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddEditTaskPage()),
            );
          },
          child: const Center(
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 35,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      // Increased padding to ensure it clears the home indicator comfortably
      padding: EdgeInsets.only(
        bottom: bottomPadding > 0 ? bottomPadding + 10 : 25,
        top: 15,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, LucideIcons.home, 'Tasks'),
          _buildNavItem(1, LucideIcons.barChart2, 'Stats'),
          const SizedBox(width: 70), // Space for FAB
          _buildNavItem(2, LucideIcons.calendar, 'Calendar'),
          _buildNavItem(3, LucideIcons.user, 'Profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    // Current index adjust because of FAB space? No, PageView index is 0-3.
    final pageIndex = index;
    final isSelected = _selectedIndex == pageIndex;

    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          pageIndex,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blue.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.blueAccent : Colors.white60,
              size: 26,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blueAccent : Colors.white38,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksView() {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state.status == TaskStatus.loading && state.tasks.isEmpty) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.white));
        }

        if (state.status == TaskStatus.error && state.tasks.isEmpty) {
          return Center(
              child: Text(state.errorMessage ?? 'An error occurred',
                  style: const TextStyle(color: Colors.white)));
        }

        final filteredTasks = state.tasks.where((task) {
          final priorityMatch =
              _priorityFilter == null || task.priority == _priorityFilter;
          final statusMatch =
              _statusFilter == null || task.isCompleted == _statusFilter;
          return priorityMatch && statusMatch;
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildFilters(),
            Expanded(
              child: filteredTasks.isEmpty
                  ? _buildEmptyState()
                  : _buildTaskList(filteredTasks),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCalendarView() {
    return Column(
      children: [
        _buildHeader(context, title: 'Calendar'),
        const Expanded(
          child: Center(
            child: Text('Calendar View Coming Soon!',
                style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsView() {
    return Column(
      children: [
        _buildHeader(context, title: 'Statistics'),
        const Expanded(
          child: Center(
            child: Text('Stats View Coming Soon!',
                style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, {String? title}) {
    final user = FirebaseAuth.instance.currentUser;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              user?.photoURL != null
                  ? CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(user!.photoURL!),
                      backgroundColor: Colors.white24,
                    )
                  : CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.blueAccent,
                      child: Text(
                        (user?.displayName?.isNotEmpty ?? false)
                            ? user!.displayName![0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
              GestureDetector(
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  if (mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.logout, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (title == null) ...[
            Text(
              'Today, ${DateFormat('d MMMM').format(DateTime.now())}',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6), fontSize: 16),
            ),
            const Text(
              'My tasks',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildSearchBar(),
          ] else
            Text(
              title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold),
            ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const TextField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: Colors.white54),
          hintText: 'Search tasks...',
          hintStyle: TextStyle(color: Colors.white54),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip(
              'All', _priorityFilter == null && _statusFilter == null, () {
            setState(() {
              _priorityFilter = null;
              _statusFilter = null;
            });
          }),
          _buildFilterChip('High', _priorityFilter == TaskPriority.high, () {
            setState(() => _priorityFilter = TaskPriority.high);
          }),
          _buildFilterChip('Completed', _statusFilter == true, () {
            setState(() => _statusFilter = true);
          }),
          _buildFilterChip('Pending', _statusFilter == false, () {
            setState(() => _statusFilter = false);
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.blueAccent
                : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(List<TaskEntity> tasks) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskCard(task);
      },
    );
  }

  Widget _buildTaskCard(TaskEntity task) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          context.read<TaskBloc>().add(RemoveTaskRequested(task.id, userId));
        }
      },
      child: GestureDetector(
        onTap: () => _navigateToAddEditTask(context, task: task),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  final userId = FirebaseAuth.instance.currentUser?.uid;
                  if (userId != null) {
                    context
                        .read<TaskBloc>()
                        .add(ToggleTaskCompletionRequested(task, userId));
                  }
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blueAccent, width: 2),
                    color: task.isCompleted
                        ? Colors.blueAccent
                        : Colors.transparent,
                  ),
                  child: task.isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('d MMM').format(task.dueDate),
                      style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.4),
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
              _buildPriorityBadge(task.priority),
            ],
          ),
        ),
      ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1, end: 0),
    );
  }

  Widget _buildPriorityBadge(TaskPriority priority) {
    Color color;
    switch (priority) {
      case TaskPriority.high:
        color = Colors.orangeAccent;
        break;
      case TaskPriority.medium:
        color = Colors.blueAccent;
        break;
      case TaskPriority.low:
        color = Colors.greenAccent;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        priority.name.toUpperCase(),
        style:
            TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt,
              size: 80, color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            'No tasks found',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6), fontSize: 18),
          ),
        ],
      ),
    );
  }

  void _navigateToAddEditTask(BuildContext context, {TaskEntity? task}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditTaskPage(task: task),
      ),
    );
  }

  Widget _buildProfileView() {
    final user = FirebaseAuth.instance.currentUser;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage:
                user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
            backgroundColor: Colors.blueAccent,
            child: user?.photoURL == null
                ? const Icon(Icons.person, size: 50, color: Colors.white)
                : null,
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 20),
          Text(
            user?.displayName ?? 'User Name',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            user?.email ?? '',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.withValues(alpha: 0.2),
              foregroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Add these icons if lucide is not available, or use FontAwesome
class LucideIcons {
  static const IconData home = Icons.grid_view_rounded;
  static const IconData barChart2 = Icons.bar_chart_rounded;
  static const IconData calendar = Icons.calendar_today_rounded;
  static const IconData user = Icons.person_outline_rounded;
}
