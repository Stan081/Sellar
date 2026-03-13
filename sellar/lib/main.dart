import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sellar/src/config/app_config.dart';
import 'package:sellar/src/config/router_config.dart';
import 'package:sellar/src/theme/app_theme.dart';
import 'package:sellar/src/services/app_services.dart';

/// Application entry point
Future<void> main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env missing or unreadable — AppConfig fallbacks will be used
  }

  // Pre-cache Public Sans to prevent blank screen on first launch
  await GoogleFonts.pendingFonts([GoogleFonts.publicSans()]);

  // Initialize app services
  await AppServices.init();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const SellarApp());
}

/// Root application widget
class SellarApp extends StatelessWidget {
  const SellarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}
