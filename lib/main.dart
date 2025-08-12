import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes.dart';
import 'theme.dart';
import 'services/local_analytics_service.dart';
import 'services/performance_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize performance service for optimal speed
  await PerformanceService().initialize();
  
  // Initialize local analytics instead of Firebase
  await LocalAnalyticsService().initialize();

  runApp(const InkwisePDFApp());
}

class InkwisePDFApp extends StatelessWidget {
  const InkwisePDFApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inkwise PDF',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: Routes.splash,
      routes: appRoutes,
    );
  }
}

