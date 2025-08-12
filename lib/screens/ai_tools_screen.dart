import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:inkwise_pdf/theme.dart';
import 'package:inkwise_pdf/widgets/tool_card.dart';
import 'package:inkwise_pdf/widgets/featured_tool_card.dart';
import 'package:inkwise_pdf/screens/tools/ai/smart_summarizer_screen.dart';
import 'package:inkwise_pdf/screens/tools/ai/offline_translator_screen.dart';
import 'package:inkwise_pdf/screens/tools/ai/voice_to_text_screen.dart';
import 'package:inkwise_pdf/screens/tools/ai/form_detector_screen.dart';
import 'package:inkwise_pdf/screens/tools/ai/keyword_analytics_screen.dart';
import 'package:inkwise_pdf/screens/tools/ai/redaction_tool_screen.dart';
import 'package:inkwise_pdf/screens/tools/ai/handwriting_recognition_screen.dart';
import 'package:inkwise_pdf/screens/tools/ai/content_cleanup_screen.dart';

class AIToolsScreen extends StatefulWidget {
  const AIToolsScreen({super.key});

  @override
  State<AIToolsScreen> createState() => _AIToolsScreenState();
}

class _AIToolsScreenState extends State<AIToolsScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI-Powered Tools"),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildFeaturedTools(),
              const SizedBox(height: 24),
              _buildAIToolsGrid(),
              const SizedBox(height: 24),
              _buildAdvancedAITools(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryPurple.withValues(alpha: 0.1),
            AppColors.primaryBlue.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryPurple.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.psychology,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "AI-Powered Features",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Advanced AI capabilities powered by on-device models",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedTools() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Featured AI Tools",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              FeaturedToolCard(
                title: "Smart PDF Summarizer",
                subtitle: "Extract key points from documents",
                icon: Icons.summarize,
                gradient: LinearGradient(
                  colors: [AppColors.primaryPurple, AppColors.primaryBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SmartSummarizerScreen()),
                ),
              ),
              const SizedBox(width: 16),
              FeaturedToolCard(
                title: "Offline Translator",
                subtitle: "Translate documents without internet",
                icon: Icons.translate,
                gradient: LinearGradient(
                  colors: [AppColors.primaryGreen, AppColors.primaryBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OfflineTranslatorScreen()),
                ),
              ),
              const SizedBox(width: 16),
              FeaturedToolCard(
                title: "Voice-to-Text Notes",
                subtitle: "Record and embed voice annotations",
                icon: Icons.mic,
                gradient: LinearGradient(
                  colors: [AppColors.primaryOrange, AppColors.primaryRed],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VoiceToTextScreen()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAIToolsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "AI Processing Tools",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        StaggeredGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            ToolCard(
              title: "Smart Summarizer",
              icon: Icons.summarize,
              color: AppColors.primaryPurple,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SmartSummarizerScreen()),
              ),
            ),
            ToolCard(
              title: "Offline Translator",
              icon: Icons.translate,
              color: AppColors.primaryGreen,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OfflineTranslatorScreen()),
              ),
            ),
            ToolCard(
              title: "Voice-to-Text",
              icon: Icons.mic,
              color: AppColors.primaryOrange,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VoiceToTextScreen()),
              ),
            ),
            ToolCard(
              title: "Form Detector",
              icon: Icons.check_box,
              color: AppColors.primaryBlue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FormDetectorScreen()),
              ),
            ),
            ToolCard(
              title: "Keyword Analytics",
              icon: Icons.analytics,
              color: AppColors.primaryGreen,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const KeywordAnalyticsScreen()),
              ),
            ),
            ToolCard(
              title: "Redaction Tool",
              icon: Icons.block,
              color: AppColors.primaryRed,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RedactionToolScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdvancedAITools() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Advanced AI Features",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        StaggeredGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            ToolCard(
              title: "Handwriting Recognition",
              icon: Icons.draw,
              color: AppColors.primaryPurple,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HandwritingRecognitionScreen()),
              ),
            ),
            ToolCard(
              title: "Content Cleanup",
              icon: Icons.cleaning_services,
              color: AppColors.primaryBlue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContentCleanupScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
