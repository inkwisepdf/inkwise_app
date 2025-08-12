import 'package:flutter/material.dart';
import 'package:inkwise_pdf/screens/splash_screen.dart';
import 'package:inkwise_pdf/screens/home_screen.dart';
import 'package:inkwise_pdf/screens/pdf_viewer_screen.dart';
import 'package:inkwise_pdf/screens/settings_screen.dart';
import 'package:inkwise_pdf/screens/find_replace_screen.dart';
import 'package:inkwise_pdf/screens/metadata_editor_screen.dart';
import 'package:inkwise_pdf/screens/ai_tools_screen.dart';
import 'package:inkwise_pdf/screens/advanced_tools_screen.dart';
import 'package:inkwise_pdf/screens/analytics_dashboard_screen.dart';

class Routes {
  static const splash = '/';
  static const home = '/home';
  static const pdfViewer = '/viewer';
  static const settings = '/settings';
  static const findReplace = '/find_replace';
  static const metadataEditor = '/metadata_editor';
  static const aiTools = '/ai_tools';
  static const advancedTools = '/advanced_tools';
  static const analyticsDashboard = '/analytics_dashboard';
}

final Map<String, WidgetBuilder> appRoutes = {
  Routes.splash: (context) => const SplashScreen(),
  Routes.home: (context) => const HomeScreen(),
  Routes.pdfViewer: (context) => const PdfViewerScreen(),
  Routes.settings: (context) => const SettingsScreen(),
  Routes.findReplace: (context) => const FindReplaceScreen(),
  Routes.metadataEditor: (context) => const MetadataEditorScreen(),
  Routes.aiTools: (context) => const AIToolsScreen(),
  Routes.advancedTools: (context) => const AdvancedToolsScreen(),
  Routes.analyticsDashboard: (context) => const AnalyticsDashboardScreen(),
};

