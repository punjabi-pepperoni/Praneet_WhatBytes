import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_auth_app/injection_container.dart' as di;
import 'package:flutter_auth_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_auth_app/features/auth/presentation/pages/splash_page.dart';
import 'package:flutter_auth_app/features/tasks/presentation/bloc/task_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (_) => di.sl<TaskBloc>()),
      ],
      child: MaterialApp(
        title: 'Flutter Auth',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          fontFamily: 'Inter',
        ),
        home: const SplashPage(),
      ),
    );
  }
}
