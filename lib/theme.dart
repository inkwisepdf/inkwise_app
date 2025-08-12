import 'package:flutter/material.dart';

// Futuristic, Professional, Minimalist Color Palette
class AppColors {
  // Primary Colors - Modern Blue Gradient
  static const primaryBlue = Color(0xFF2563EB);      // Deep Blue
  static const secondaryBlue = Color(0xFF3B82F6);    // Medium Blue
  static const accentBlue = Color(0xFF60A5FA);       // Light Blue
  static const lightBlue = Color(0xFFDBEAFE);        // Very Light Blue
  static const darkBlue = Color(0xFF1E40AF);         // Dark Blue
  
  // Accent Colors - Professional Palette
  static const primaryGreen = Color(0xFF10B981);     // Emerald Green
  static const primaryPurple = Color(0xFF8B5CF6);    // Purple
  static const primaryOrange = Color(0xFFF59E0B);    // Amber
  static const primaryRed = Color(0xFFEF4444);       // Red
  static const primaryTeal = Color(0xFF14B8A6);      // Teal
  static const primaryIndigo = Color(0xFF6366F1);    // Indigo
  
  // Neutral Colors - Minimalist Grays
  static const backgroundLight = Color(0xFFFAFAFA);  // Off White
  static const surfaceLight = Color(0xFFFFFFFF);     // Pure White
  static const backgroundDark = Color(0xFF0F0F23);   // Deep Dark
  static const surfaceDark = Color(0xFF1A1A2E);      // Dark Surface
  
  // Text Colors - High Contrast
  static const textPrimaryLight = Color(0xFF1F2937); // Dark Gray
  static const textSecondaryLight = Color(0xFF6B7280); // Medium Gray
  static const textPrimaryDark = Color(0xFFF9FAFB);  // Light Gray
  static const textSecondaryDark = Color(0xFFD1D5DB); // Medium Light Gray
  
  // Gradient Colors - Futuristic
  static const gradientStart = Color(0xFF667EEA);    // Purple Blue
  static const gradientEnd = Color(0xFF764BA2);      // Purple
  static const gradientBlueStart = Color(0xFF4F46E5); // Indigo
  static const gradientBlueEnd = Color(0xFF7C3AED);  // Purple
  
  // Success/Error Colors
  static const success = Color(0xFF10B981);          // Green
  static const warning = Color(0xFFF59E0B);          // Amber
  static const error = Color(0xFFEF4444);            // Red
  static const info = Color(0xFF3B82F6);             // Blue
  
  // Glass Effect Colors
  static const glassLight = Color(0x80FFFFFF);       // Semi-transparent White
  static const glassDark = Color(0x80000000);        // Semi-transparent Black
  
  // Shadow Colors
  static const shadowLight = Color(0x1A000000);      // Light Shadow
  static const shadowMedium = Color(0x33000000);     // Medium Shadow
  static const shadowDark = Color(0x4D000000);       // Dark Shadow
}

// Modern Typography Scale
class AppTypography {
  static const fontFamily = 'Inter'; // Modern, clean font
  
  static const displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );
  
  static const displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
  );
  
  static const headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
  );
  
  static const headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.15,
  );
  
  static const titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );
  
  static const titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  );
  
  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );
  
  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );
  
  static const labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );
  
  static const labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );
  
  static const labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );
}

// Modern Border Radius
class AppRadius {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const full = 999.0;
}

// Modern Spacing
class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primaryBlue,
  scaffoldBackgroundColor: AppColors.backgroundLight,
  cardColor: AppColors.surfaceLight,
  
  // Modern App Bar Theme
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.surfaceLight,
    foregroundColor: AppColors.textPrimaryLight,
    elevation: 0,
    shadowColor: AppColors.shadowLight,
    centerTitle: false,
    titleTextStyle: AppTypography.headlineMedium.copyWith(
      color: AppColors.textPrimaryLight,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: const IconThemeData(
      color: AppColors.textPrimaryLight,
      size: 24,
    ),
  ),
  
  // Modern Floating Action Button Theme
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryBlue,
    foregroundColor: Colors.white,
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
    ),
  ),
  
  // Modern Elevated Button Theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: Colors.white,
      elevation: 2,
      shadowColor: AppColors.shadowMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      textStyle: AppTypography.labelLarge.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  
  // Modern Outlined Button Theme
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primaryBlue,
      side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      textStyle: AppTypography.labelLarge.copyWith(
        color: AppColors.primaryBlue,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  
  // Modern Text Button Theme
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primaryBlue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      textStyle: AppTypography.labelLarge.copyWith(
        color: AppColors.primaryBlue,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  
  // Modern Card Theme
  cardTheme: CardThemeData(
    color: AppColors.surfaceLight,
    elevation: 2,
    shadowColor: AppColors.shadowLight,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
    ),
    margin: const EdgeInsets.all(AppSpacing.sm),
  ),
  
  // Modern Text Theme
  textTheme: TextTheme(
    displayLarge: AppTypography.displayLarge.copyWith(
      color: AppColors.textPrimaryLight,
    ),
    displayMedium: AppTypography.displayMedium.copyWith(
      color: AppColors.textPrimaryLight,
    ),
    headlineLarge: AppTypography.headlineLarge.copyWith(
      color: AppColors.textPrimaryLight,
    ),
    headlineMedium: AppTypography.headlineMedium.copyWith(
      color: AppColors.textPrimaryLight,
    ),
    titleLarge: AppTypography.titleLarge.copyWith(
      color: AppColors.textPrimaryLight,
    ),
    titleMedium: AppTypography.titleMedium.copyWith(
      color: AppColors.textPrimaryLight,
    ),
    bodyLarge: AppTypography.bodyLarge.copyWith(
      color: AppColors.textPrimaryLight,
    ),
    bodyMedium: AppTypography.bodyMedium.copyWith(
      color: AppColors.textSecondaryLight,
    ),
    labelLarge: AppTypography.labelLarge.copyWith(
      color: AppColors.textPrimaryLight,
    ),
    labelMedium: AppTypography.labelMedium.copyWith(
      color: AppColors.textSecondaryLight,
    ),
  ),
  
  // Modern Color Scheme
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: AppColors.primaryBlue,
    secondary: AppColors.secondaryBlue,
    surface: AppColors.surfaceLight,
    background: AppColors.backgroundLight,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: AppColors.textPrimaryLight,
    onBackground: AppColors.textPrimaryLight,
    outline: AppColors.textSecondaryLight.withOpacity(0.2),
    outlineVariant: AppColors.textSecondaryLight.withOpacity(0.1),
  ),
  
  // Modern Input Decoration Theme
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceLight,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(
        color: AppColors.textSecondaryLight.withOpacity(0.2),
        width: 1,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(
        color: AppColors.textSecondaryLight.withOpacity(0.2),
        width: 1,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(
        color: AppColors.primaryBlue,
        width: 2,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(
        color: AppColors.error,
        width: 1,
      ),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.md,
    ),
    labelStyle: AppTypography.bodyMedium.copyWith(
      color: AppColors.textSecondaryLight,
    ),
    hintStyle: AppTypography.bodyMedium.copyWith(
      color: AppColors.textSecondaryLight.withOpacity(0.7),
    ),
  ),
  
  // Modern Icon Theme
  iconTheme: const IconThemeData(
    color: AppColors.textPrimaryLight,
    size: 24,
  ),
  
  // Modern Divider Theme
  dividerTheme: DividerThemeData(
    color: AppColors.textSecondaryLight.withOpacity(0.1),
    thickness: 1,
    space: AppSpacing.md,
  ),
  
  // Modern Switch Theme
  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.primaryBlue;
      }
      return AppColors.textSecondaryLight;
    }),
    trackColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.primaryBlue.withOpacity(0.3);
      }
      return AppColors.textSecondaryLight.withOpacity(0.2);
    }),
  ),
  
  // Modern Slider Theme
  sliderTheme: SliderThemeData(
    activeTrackColor: AppColors.primaryBlue,
    inactiveTrackColor: AppColors.textSecondaryLight.withOpacity(0.2),
    thumbColor: AppColors.primaryBlue,
    overlayColor: AppColors.primaryBlue.withOpacity(0.1),
    valueIndicatorColor: AppColors.primaryBlue,
    valueIndicatorTextStyle: AppTypography.labelMedium.copyWith(
      color: Colors.white,
    ),
  ),
  
  // Modern Chip Theme
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.lightBlue,
    selectedColor: AppColors.primaryBlue,
    disabledColor: AppColors.textSecondaryLight.withOpacity(0.1),
    labelStyle: AppTypography.labelMedium.copyWith(
      color: AppColors.primaryBlue,
    ),
    secondaryLabelStyle: AppTypography.labelMedium.copyWith(
      color: Colors.white,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.full),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
  ),
  
  // Modern Bottom Navigation Bar Theme
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.surfaceLight,
    selectedItemColor: AppColors.primaryBlue,
    unselectedItemColor: AppColors.textSecondaryLight,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),
  
  // Modern Tab Bar Theme
  tabBarTheme: TabBarThemeData(
    labelColor: AppColors.primaryBlue,
    unselectedLabelColor: AppColors.textSecondaryLight,
    indicatorColor: AppColors.primaryBlue,
    indicatorSize: TabBarIndicatorSize.tab,
  ),
  
  // Modern Dialog Theme
  dialogTheme: DialogThemeData(
    backgroundColor: AppColors.surfaceLight,
    elevation: 8,
    shadowColor: AppColors.shadowDark,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
    ),
    titleTextStyle: AppTypography.headlineMedium.copyWith(
      color: AppColors.textPrimaryLight,
    ),
    contentTextStyle: AppTypography.bodyMedium.copyWith(
      color: AppColors.textSecondaryLight,
    ),
  ),
  
  // Modern Snackbar Theme
  snackBarTheme: SnackBarThemeData(
    backgroundColor: AppColors.textPrimaryLight,
    contentTextStyle: AppTypography.bodyMedium.copyWith(
      color: Colors.white,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
    behavior: SnackBarBehavior.floating,
  ),
  
  // Modern Popup Menu Theme
  popupMenuTheme: PopupMenuThemeData(
    color: AppColors.surfaceLight,
    elevation: 8,
    shadowColor: AppColors.shadowDark,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
    textStyle: AppTypography.bodyMedium.copyWith(
      color: AppColors.textPrimaryLight,
    ),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.primaryBlue,
  scaffoldBackgroundColor: AppColors.backgroundDark,
  cardColor: AppColors.surfaceDark,
  
  // Modern App Bar Theme - Dark
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.surfaceDark,
    foregroundColor: AppColors.textPrimaryDark,
    elevation: 0,
    shadowColor: AppColors.shadowLight,
    centerTitle: false,
    titleTextStyle: AppTypography.headlineMedium.copyWith(
      color: AppColors.textPrimaryDark,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: const IconThemeData(
      color: AppColors.textPrimaryDark,
      size: 24,
    ),
  ),
  
  // Modern Floating Action Button Theme - Dark
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryBlue,
    foregroundColor: Colors.white,
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
    ),
  ),
  
  // Modern Elevated Button Theme - Dark
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: Colors.white,
      elevation: 2,
      shadowColor: AppColors.shadowMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      textStyle: AppTypography.labelLarge.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  
  // Modern Outlined Button Theme - Dark
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primaryBlue,
      side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      textStyle: AppTypography.labelLarge.copyWith(
        color: AppColors.primaryBlue,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  
  // Modern Text Button Theme - Dark
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primaryBlue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      textStyle: AppTypography.labelLarge.copyWith(
        color: AppColors.primaryBlue,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  
  // Modern Card Theme - Dark
  cardTheme: CardThemeData(
    color: AppColors.surfaceDark,
    elevation: 2,
    shadowColor: AppColors.shadowLight,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
    ),
    margin: const EdgeInsets.all(AppSpacing.sm),
  ),
  
  // Modern Text Theme - Dark
  textTheme: TextTheme(
    displayLarge: AppTypography.displayLarge.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    displayMedium: AppTypography.displayMedium.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    headlineLarge: AppTypography.headlineLarge.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    headlineMedium: AppTypography.headlineMedium.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    titleLarge: AppTypography.titleLarge.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    titleMedium: AppTypography.titleMedium.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    bodyLarge: AppTypography.bodyLarge.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    bodyMedium: AppTypography.bodyMedium.copyWith(
      color: AppColors.textSecondaryDark,
    ),
    labelLarge: AppTypography.labelLarge.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    labelMedium: AppTypography.labelMedium.copyWith(
      color: AppColors.textSecondaryDark,
    ),
  ),
  
  // Modern Color Scheme - Dark
  colorScheme: ColorScheme.fromSwatch().copyWith(
    brightness: Brightness.dark,
    primary: AppColors.primaryBlue,
    secondary: AppColors.secondaryBlue,
    surface: AppColors.surfaceDark,
    background: AppColors.backgroundDark,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: AppColors.textPrimaryDark,
    onBackground: AppColors.textPrimaryDark,
    outline: AppColors.textSecondaryDark.withOpacity(0.2),
    outlineVariant: AppColors.textSecondaryDark.withOpacity(0.1),
  ),
  
  // Modern Input Decoration Theme - Dark
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceDark,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(
        color: AppColors.textSecondaryDark.withOpacity(0.2),
        width: 1,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(
        color: AppColors.textSecondaryDark.withOpacity(0.2),
        width: 1,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(
        color: AppColors.primaryBlue,
        width: 2,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(
        color: AppColors.error,
        width: 1,
      ),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.md,
    ),
    labelStyle: AppTypography.bodyMedium.copyWith(
      color: AppColors.textSecondaryDark,
    ),
    hintStyle: AppTypography.bodyMedium.copyWith(
      color: AppColors.textSecondaryDark.withOpacity(0.7),
    ),
  ),
  
  // Modern Icon Theme - Dark
  iconTheme: const IconThemeData(
    color: AppColors.textPrimaryDark,
    size: 24,
  ),
  
  // Modern Divider Theme - Dark
  dividerTheme: DividerThemeData(
    color: AppColors.textSecondaryDark.withOpacity(0.1),
    thickness: 1,
    space: AppSpacing.md,
  ),
  
  // Modern Switch Theme - Dark
  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.primaryBlue;
      }
      return AppColors.textSecondaryDark;
    }),
    trackColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.primaryBlue.withOpacity(0.3);
      }
      return AppColors.textSecondaryDark.withOpacity(0.2);
    }),
  ),
  
  // Modern Slider Theme - Dark
  sliderTheme: SliderThemeData(
    activeTrackColor: AppColors.primaryBlue,
    inactiveTrackColor: AppColors.textSecondaryDark.withOpacity(0.2),
    thumbColor: AppColors.primaryBlue,
    overlayColor: AppColors.primaryBlue.withOpacity(0.1),
    valueIndicatorColor: AppColors.primaryBlue,
    valueIndicatorTextStyle: AppTypography.labelMedium.copyWith(
      color: Colors.white,
    ),
  ),
  
  // Modern Chip Theme - Dark
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
    selectedColor: AppColors.primaryBlue,
    disabledColor: AppColors.textSecondaryDark.withOpacity(0.1),
    labelStyle: AppTypography.labelMedium.copyWith(
      color: AppColors.primaryBlue,
    ),
    secondaryLabelStyle: AppTypography.labelMedium.copyWith(
      color: Colors.white,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.full),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
  ),
  
  // Modern Bottom Navigation Bar Theme - Dark
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.surfaceDark,
    selectedItemColor: AppColors.primaryBlue,
    unselectedItemColor: AppColors.textSecondaryDark,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),
  
  // Modern Tab Bar Theme - Dark
  tabBarTheme: TabBarThemeData(
    labelColor: AppColors.primaryBlue,
    unselectedLabelColor: AppColors.textSecondaryDark,
    indicatorColor: AppColors.primaryBlue,
    indicatorSize: TabBarIndicatorSize.tab,
  ),
  
  // Modern Dialog Theme - Dark
  dialogTheme: DialogThemeData(
    backgroundColor: AppColors.surfaceDark,
    elevation: 8,
    shadowColor: AppColors.shadowDark,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
    ),
    titleTextStyle: AppTypography.headlineMedium.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    contentTextStyle: AppTypography.bodyMedium.copyWith(
      color: AppColors.textSecondaryDark,
    ),
  ),
  
  // Modern Snackbar Theme - Dark
  snackBarTheme: SnackBarThemeData(
    backgroundColor: AppColors.textPrimaryDark,
    contentTextStyle: AppTypography.bodyMedium.copyWith(
      color: AppColors.backgroundDark,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
    behavior: SnackBarBehavior.floating,
  ),
  
  // Modern Popup Menu Theme - Dark
  popupMenuTheme: PopupMenuThemeData(
    color: AppColors.surfaceDark,
    elevation: 8,
    shadowColor: AppColors.shadowDark,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
    textStyle: AppTypography.bodyMedium.copyWith(
      color: AppColors.textPrimaryDark,
    ),
  ),
);

