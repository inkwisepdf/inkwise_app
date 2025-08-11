import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/pdf_viewer_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/find_replace_screen.dart';
import 'screens/metadata_editor_screen.dart';
import 'screens/ai_tools_screen.dart';
import 'screens/advanced_tools_screen.dart';

class Routes {
  static const splash = '/';
  static const home = '/home';
  static const pdfViewer = '/viewer';
  static const settings = '/settings';
  static const findReplace = '/find_replace';
  static const metadataEditor = '/metadata_editor';
  static const aiTools = '/ai_tools';
  static const advancedTools = '/advanced_tools';
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
};
