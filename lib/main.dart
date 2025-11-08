import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'theme_provider.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import 'splash_screen.dart';


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
