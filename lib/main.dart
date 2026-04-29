import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:total_x/firebase_options.dart';
import 'package:total_x/viewmodels/auth_viewmodel.dart';
import 'package:total_x/viewmodels/user_viewmodel.dart';
import 'package:total_x/views/login_view.dart';
import 'package:total_x/views/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
      ],
      child: MaterialApp(
        title: 'TotalX Machine Test',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF000000),
            brightness: Brightness.light,
          ),
          fontFamily: 'Inter',
        ),
        home: Consumer<AuthViewModel>(
          builder: (context, authVM, child) {
            if (authVM.user != null) {
              return const HomeView();
            }
            return const LoginView();
          },
        ),
      ),
    );
  }
}
