import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../routes.dart';
import '../theme.dart';
import '../services/performance_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _gradientController;
  
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<double> _gradientOpacity;

  @override
  void initState() {
    super.initState();
    
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _gradientController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );
    
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );
    
    _gradientOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _gradientController, curve: Curves.easeInOut),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    // Start animations immediately for faster perceived performance
    _logoController.forward();
    _textController.forward();
    _gradientController.forward();
    
    // Preload essential services for faster app startup
    await _preloadServices();
    
    // Navigate to home after shorter delay for better performance
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      Navigator.pushReplacementNamed(context, Routes.home);
    }
  }

  // Preload essential services for faster performance
  Future<void> _preloadServices() async {
    // Preload performance service
    await PerformanceService().initialize();
    
    // Preload common directories
    await getApplicationDocumentsDirectory();
    
    // Preload theme data
    await Future.microtask(() {
      // Warm up theme calculations
      AppColors.gradientStart;
      AppColors.gradientEnd;
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _gradientOpacity,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.gradientStart.withOpacity(_gradientOpacity.value * 0.1),
                      AppColors.gradientEnd.withOpacity(_gradientOpacity.value * 0.05),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Floating particles effect
          ...List.generate(20, (index) => _buildParticle(index)),
          
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with animation
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScale.value,
                      child: Opacity(
                        opacity: _logoOpacity.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.gradientStart, AppColors.gradientEnd],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.gradientStart.withOpacity(0.4),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: AppSpacing.xl),
                
                // App name with animation
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textOpacity.value,
                      child: Column(
                        children: [
                          Text(
                            "Inkwise PDF",
                            style: AppTypography.displayLarge.copyWith(
                              fontWeight: FontWeight.w800,
                              background: Paint()
                                ..shader = const LinearGradient(
                                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                                ).createShader(const Rect.fromLTWH(0.0, 0.0, 300.0, 70.0)),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            "Professional PDF Editor",
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.textSecondaryLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: AppSpacing.xxl),
                
                // Loading indicator
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textOpacity.value,
                      child: Column(
                        children: [
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.gradientStart,
                              ),
                              backgroundColor: AppColors.gradientStart.withOpacity(0.1),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            "Loading...",
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Bottom info
          Positioned(
            bottom: AppSpacing.xl,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _textController,
              builder: (context, child) {
                return Opacity(
                  opacity: _textOpacity.value,
                  child: Column(
                    children: [
                      Text(
                        "Version 1.0.0",
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        "© 2024 Inkwise PDF. All rights reserved.",
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textSecondaryLight.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticle(int index) {
    final random = (index * 12345) % 1000 / 1000.0;
    final size = 2.0 + random * 4.0;
    final left = random * MediaQuery.of(context).size.width;
    final top = random * MediaQuery.of(context).size.height;
    final duration = Duration(milliseconds: 3000 + (random * 2000).toInt());
    
    return Positioned(
      left: left,
      top: top,
      child: AnimatedBuilder(
        animation: _gradientController,
        builder: (context, child) {
          return Opacity(
            opacity: _gradientOpacity.value * (0.3 + random * 0.4),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: AppColors.gradientStart.withOpacity(0.6),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gradientStart.withOpacity(0.3),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

