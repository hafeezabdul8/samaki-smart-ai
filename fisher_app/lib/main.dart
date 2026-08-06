import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'services/auth_provider.dart';
import 'services/api_service.dart';
import 'services/language_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        Provider(create: (_) => ApiService()),
      ],
      child: const SamakiApp(),
    ),
  );
}

class SamakiApp extends StatelessWidget {
  const SamakiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();
    return MaterialApp(
      title: 'Samaki Smart AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      locale: langProvider.locale,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isLoggedIn) return const HomeScreen();
          return const LoginScreen();
        },
      ),
    );
  }
}