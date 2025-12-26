import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_auth_app/core/widgets/gradient_background.dart';
import 'package:flutter_auth_app/features/auth/presentation/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_auth_app/features/tasks/presentation/pages/task_list_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _handleNavigation();
  }

  void _handleNavigation() async {
    await Future.delayed(const Duration(milliseconds: 3000));
    if (!mounted) return;

    // Use authStateChanges().first to wait for Firebase to initialize the user state
    final user = await FirebaseAuth.instance.authStateChanges().first;

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            user != null ? const TaskListPage() : const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with Pulse/Shimmer
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyan.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.waves,
                  size: 60,
                  color: Colors.black,
                ),
              )
                  .animate()
                  .fadeIn(duration: 800.ms, curve: Curves.easeOut)
                  .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.0, 1.0),
                      duration: 800.ms,
                      curve: Curves.elasticOut)
                  .then()
                  .shimmer(
                      duration: 1500.ms, color: Colors.cyan.withOpacity(0.2)),

              const SizedBox(height: 30),

              // App Name with elegant animation
              const Text(
                'WHATBYTES',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 8,
                ),
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 800.ms)
                  .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),

              const SizedBox(height: 10),

              // Subtitle
              Text(
                "Praneet Singh Oberoi",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1.2,
                ),
              ).animate().fadeIn(delay: 800.ms, duration: 1000.ms),
            ],
          ),
        ),
      ),
    );
  }
}
