import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hrd_app/features/auth/screens/login_screen.dart';
import 'core/theme/app_theme.dart';
import 'package:hrd_app/core/utils/crypto_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  try {
    CryptoUtils().initialize();
    debugPrint('✅ Crypto initialized');
  } catch (e) {
    debugPrint('❌ Crypto initialization failed: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EZ HRD APP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const LoginScreen(),
    );
  }
}
