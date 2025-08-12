import 'dart:io';

void main() async {
  print('🔍 Comprehensive Inkwise PDF Project Verification\n');
  print('=' * 60);

  // 1. Check project structure
  print('\n1. 📁 Project Structure Verification');
  await verifyProjectStructure();

  // 2. Check dependencies
  print('\n2. 📦 Dependencies Verification');
  await verifyDependencies();

  // 3. Check assets
  print('\n3. 🎨 Assets Verification');
  await verifyAssets();

  // 4. Check imports and code quality
  print('\n4. 🔧 Code Quality Verification');
  await verifyCodeQuality();

  // 5. Check features implementation
  print('\n5. ⚡ Features Implementation Verification');
  await verifyFeatures();

  print('\n' + '=' * 60);
  print('✅ Verification Complete!');
}

Future<void> verifyProjectStructure() async {
  final requiredDirs = [
    'lib',
    'lib/services',
    'lib/screens',
    'lib/screens/tools',
    'lib/screens/tools/ai',
    'lib/screens/tools/advanced',
    'lib/screens/tools/security',
    'lib/widgets',
    'lib/features',
    'lib/utils',
    'assets',
    'assets/icons',
    'assets/fonts',
    'assets/images',
    'assets/models',
    'assets/translations',
    'test',
    'android',
  ];

  for (final dir in requiredDirs) {
    if (await Directory(dir).exists()) {
      print('  ✅ $dir');
    } else {
      print('  ❌ $dir (missing)');
    }
  }
}

Future<void> verifyDependencies() async {
  final pubspecContent = await File('pubspec.yaml').readAsString();
  
  // Check for deprecated packages
  final deprecatedPackages = [
    'tflite_flutter',
    'tflite_flutter_helper',
    'flutter_clipboard',
    'language_detector',
    'image_editor_plus',
    'flutter_slidable',
    'shimmer',
  ];

  for (final package in deprecatedPackages) {
    if (pubspecContent.contains('$package:')) {
      print('  ❌ $package (deprecated - should be removed)');
    } else {
      print('  ✅ $package (properly removed)');
    }
  }

  // Check for required packages
  final requiredPackages = [
    'flutter:',
    'pdf:',
    'pdf_render:',
    'syncfusion_flutter_pdf:',
    'syncfusion_flutter_pdfviewer:',
    'flutter_tesseract_ocr:',
    'permission_handler:',
    'file_picker:',
    'path_provider:',
    'image_picker:',
    'share_plus:',
    'ml_algo:',
    'ml_dataframe:',
    'ml_preprocessing:',
    'speech_to_text:',
    'flutter_tts:',
    'image:',
    'sqflite:',
    'hive:',
    'encrypt:',
    'crypto:',
    'flutter_staggered_grid_view:',
    'fl_chart:',
    'google_ml_kit:',
    'archive:',
    'mime:',
    'provider:',
    'flutter_local_notifications:',
  ];

  for (final package in requiredPackages) {
    if (pubspecContent.contains(package)) {
      print('  ✅ $package');
    } else {
      print('  ❌ $package (missing)');
    }
  }
}

Future<void> verifyAssets() async {
  // Check required asset files
  final requiredAssets = [
    'assets/icons/add_text.png',
    'assets/icons/edit.png',
    'assets/icons/favorites.png',
    'assets/icons/find_replace.png',
    'assets/icons/grayscale.png',
    'assets/icons/merge.png',
    'assets/icons/metadata.png',
    'assets/icons/ocr.png',
    'assets/icons/rotate.png',
    'assets/icons/secure_lock.png',
    'assets/icons/split.png',
    'assets/icons/watermark.png',
    'assets/fonts/Inter-Regular.ttf',
    'assets/fonts/Inter-Medium.ttf',
    'assets/fonts/Inter-SemiBold.ttf',
    'assets/fonts/Inter-Bold.ttf',
    'assets/fonts/Inter-ExtraBold.ttf',
    'assets/fonts/Roboto-Regular.ttf',
    'assets/fonts/Roboto-Bold.ttf',
    'assets/fonts/Poppins-Regular.ttf',
    'assets/fonts/Poppins-Bold.ttf',
    'assets/images/splash_image.png',
    'assets/models/translation_model.json',
    'assets/models/translation_vocab.json',
    'assets/models/tokenizer.json',
    'assets/models/summarizer_model.json',
    'assets/models/vocab.json',
    'assets/translations/en.json',
  ];

  for (final asset in requiredAssets) {
    if (await File(asset).exists()) {
      print('  ✅ $asset');
    } else {
      print('  ❌ $asset (missing)');
    }
  }
}

Future<void> verifyCodeQuality() async {
  // Check for common issues
  final dartFiles = await findDartFiles('lib');
  
  for (final file in dartFiles) {
    final content = await File(file).readAsString();
    
    // Check for deprecated imports
    if (content.contains('import.*flutter_clipboard')) {
      print('  ❌ $file: Uses deprecated flutter_clipboard');
    }
    
    if (content.contains('import.*tflite_flutter')) {
      print('  ❌ $file: Uses deprecated tflite_flutter');
    }
    
    // Check for proper imports
    if (content.contains('import.*ml_algo') && content.contains('import.*ml_dataframe')) {
      print('  ✅ $file: Uses modern ML libraries');
    }
    
    // Check for proper error handling
    if (content.contains('try {') && content.contains('} catch (e) {')) {
      print('  ✅ $file: Has proper error handling');
    }
  }
}

Future<void> verifyFeatures() async {
  final features = [
    'PDF Viewer',
    'PDF Editor',
    'OCR (Text Recognition)',
    'PDF Compression',
    'PDF Merge',
    'PDF Split',
    'PDF Rotation',
    'PDF Watermark',
    'PDF Password Protection',
    'PDF Grayscale Conversion',
    'PDF Image Extraction',
    'Metadata Editor',
    'Find & Replace',
    'AI Summarization',
    'Offline Translation',
    'Voice to Text',
    'Handwriting Recognition',
    'Form Detection',
    'Content Cleanup',
    'Redaction Tool',
    'Keyword Analytics',
    'Smart Summarizer',
    'Auto Tagging',
    'Batch Processing',
    'Layout Designer',
    'Table Extractor',
    'Dual Page View',
    'Version History',
    'Color Converter',
    'Custom Stamps',
    'PDF Indexer',
    'Encryption',
    'Secure Vault',
    'Performance Monitor',
    'Analytics Dashboard',
    'Local Analytics',
    'File Management',
    'Image Optimization',
  ];

  for (final feature in features) {
    // Check if feature is implemented by looking for related files
    final hasImplementation = await checkFeatureImplementation(feature);
    if (hasImplementation) {
      print('  ✅ $feature');
    } else {
      print('  ❌ $feature (not implemented)');
    }
  }
}

Future<List<String>> findDartFiles(String directory) async {
  final List<String> files = [];
  final dir = Directory(directory);
  
  if (await dir.exists()) {
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        files.add(entity.path);
      }
    }
  }
  
  return files;
}

Future<bool> checkFeatureImplementation(String feature) async {
  final dartFiles = await findDartFiles('lib');
  final featureLower = feature.toLowerCase();
  
  for (final file in dartFiles) {
    final content = await File(file).readAsString();
    if (content.toLowerCase().contains(featureLower.replaceAll(' ', '_')) ||
        content.toLowerCase().contains(featureLower.replaceAll(' ', ''))) {
      return true;
    }
  }
  
  return false;
}