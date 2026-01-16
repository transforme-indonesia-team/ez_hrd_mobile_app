import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:hrd_app/core/providers/theme_provider.dart';
import 'package:hrd_app/core/providers/auth_provider.dart';
import 'package:hrd_app/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'package:hrd_app/core/utils/crypto_utils.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hrd_app/data/services/base_api_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

AuthProvider? _authProviderRef;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('id_ID', null);

  try {
    CryptoUtils().initialize();
    // ignore: empty_catches
  } catch (e) {}

  final themeProvider = ThemeProvider();
  await themeProvider.initialize();

  final authProvider = AuthProvider();
  await authProvider.initialize();
  _authProviderRef = authProvider;

  BaseApiService().setUnauthorizedCallback(() {
    _handleUnauthorized();
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: authProvider),
      ],
      child: const MyApp(),
    ),
  );
}

void _handleUnauthorized() async {
  await _authProviderRef?.logout();

  navigatorKey.currentState?.pushNamedAndRemoveUntil(
    AppRoutes.login,
    (route) => false,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Consumer2<ThemeProvider, AuthProvider>(
          builder: (context, themeProvider, authProvider, child) {
            return MaterialApp(
              navigatorKey: navigatorKey,
              title: 'EZ HRD APP',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeProvider.themeMode,
              initialRoute: authProvider.isAuthenticated
                  ? AppRoutes.dashboard
                  : AppRoutes.initialRoute,
              onGenerateRoute: AppRoutes.onGenerateRoute,
            );
          },
        );
      },
    );
  }
}
