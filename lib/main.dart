import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'theme_provider.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDvIMBji4zlxC6JwZgMWCQC9IMfTJsz0Gw",
      authDomain: "final-project-863a1.firebaseapp.com",
      projectId: "final-project-863a1",
      storageBucket: "final-project-863a1.firebasestorage.app",
      messagingSenderId: "850242780596",
      appId: "1:850242780596:web:de56bc46eeeea39fe346e1",
      measurementId: "G-ND7Q74WTXF",
    ),
  );
  runApp(const MediCareApp());
}

class MediCareApp extends StatelessWidget {
  const MediCareApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'MediCare+',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.getTheme(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/home': (context) => const HomeScreen(),
            },
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}