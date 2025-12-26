import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_auth_app/core/widgets/gradient_background.dart';
import 'package:flutter_auth_app/features/auth/domain/usecases/social_login.dart';
import 'package:flutter_auth_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_auth_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_auth_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_auth_app/features/auth/presentation/widgets/auth_button.dart';
import 'package:flutter_auth_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:flutter_auth_app/features/auth/presentation/widgets/social_button.dart';
import 'package:flutter_auth_app/core/widgets/pressable_scale.dart';
import 'package:flutter_auth_app/features/tasks/presentation/pages/task_list_page.dart';
import 'package:flutter_auth_app/features/auth/presentation/pages/sign_up_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all fields'),
          backgroundColor: Colors.orangeAccent,
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    context.read<AuthBloc>().add(
          AuthLoginRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          ),
        );
  }

  void _onGooglePressed() {
    context
        .read<AuthBloc>()
        .add(const AuthSocialLoginRequested(SocialProvider.google));
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;

    // Dynamic spacing
    final double topSpacing = isSmallScreen ? 30 : 60;
    final double sectionSpacing = isSmallScreen ? 25 : 40;
    final double itemSpacing = isSmallScreen ? 15 : 20;

    return Scaffold(
      body: GradientBackground(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.redAccent,
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            }
            if (state is AuthAuthenticated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Welcome back, ${state.user.displayName ?? "User"}!'),
                  backgroundColor: Colors.greenAccent,
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
              // Navigate to Home
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const TaskListPage()),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: topSpacing),
                          // Logo
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.waves,
                                size: 50, color: Colors.black),
                          )
                              .animate()
                              .fadeIn(duration: 800.ms, curve: Curves.easeOut)
                              .scale(
                                  begin: const Offset(0.95, 0.95),
                                  curve: Curves.easeOut,
                                  duration: 600.ms),

                          SizedBox(height: sectionSpacing),

                          const Text(
                            'Welcome Back!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 800.ms, curve: Curves.easeOut)
                              .slideY(
                                  begin: 0.1,
                                  end: 0,
                                  duration: 600.ms,
                                  curve: Curves.easeOut),

                          SizedBox(height: sectionSpacing),

                          AuthTextField(
                            label: 'Email ID',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                          )
                              .animate()
                              .fadeIn(
                                  delay: 200.ms,
                                  duration: 600.ms,
                                  curve: Curves.easeOut)
                              .slideX(
                                  begin: -0.05,
                                  end: 0,
                                  duration: 600.ms,
                                  curve: Curves.easeOut),

                          SizedBox(height: itemSpacing),

                          AuthTextField(
                            label: 'Password',
                            controller: _passwordController,
                            isPassword: true,
                          )
                              .animate()
                              .fadeIn(
                                  delay: 300.ms,
                                  duration: 600.ms,
                                  curve: Curves.easeOut)
                              .slideX(
                                  begin: -0.05,
                                  end: 0,
                                  duration: 600.ms,
                                  curve: Curves.easeOut),

                          const SizedBox(height: 40),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: AuthButton(
                              text: 'Log in',
                              onPressed: _onLoginPressed,
                              isLoading: isLoading,
                            ),
                          )
                              .animate()
                              .fadeIn(
                                  delay: 400.ms,
                                  duration: 600.ms,
                                  curve: Curves.easeOut)
                              .slideY(
                                  begin: 0.1,
                                  end: 0,
                                  duration: 600.ms,
                                  curve: Curves.easeOut),

                          SizedBox(height: itemSpacing),

                          Row(
                            children: [
                              const Expanded(
                                  child: Divider(color: Colors.white24)),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'or login with',
                                  style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.6)),
                                ),
                              ),
                              const Expanded(
                                  child: Divider(color: Colors.white24)),
                            ],
                          ).animate().fadeIn(delay: 500.ms, duration: 600.ms),

                          SizedBox(height: itemSpacing),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SocialButton(
                                imagePath: 'assets/images/google_logo.png',
                                color: Colors.white,
                                onTap: _onGooglePressed,
                              ),
                              const SizedBox(width: 20),
                              SocialButton(
                                icon: FontAwesomeIcons.facebookF,
                                color: const Color(0xFF1877F2),
                                iconColor: Colors.white,
                                onTap: () {},
                              ),
                              const SizedBox(width: 20),
                              SocialButton(
                                icon: FontAwesomeIcons.apple,
                                color: Colors.black,
                                iconColor: Colors.white,
                                onTap: () {},
                              ),
                            ],
                          )
                              .animate()
                              .fadeIn(delay: 600.ms, duration: 600.ms)
                              .scale(
                                  begin: const Offset(0.9, 0.9),
                                  duration: 600.ms,
                                  curve: Curves.easeOutBack),

                          const Spacer(),

                          SizedBox(height: sectionSpacing),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15, // Reduced from 18
                                ),
                              ),
                              PressableScale(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const SignUpPage()),
                                  );
                                },
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15, // Reduced from 18
                                  ),
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 700.ms, duration: 600.ms),

                          SizedBox(
                              height: MediaQuery.of(context).size.height *
                                  0.2), // Shifted upward by 20%
                          SizedBox(height: itemSpacing),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
