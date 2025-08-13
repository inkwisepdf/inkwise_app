import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:inkwise_pdf/theme.dart';
import 'package:inkwise_pdf/widgets/tool_card.dart';
import 'package:inkwise_pdf/widgets/featured_tool_card.dart';
import 'package:inkwise_pdf/screens/tools/advanced/table_extractor_screen.dart';
import 'package:inkwise_pdf/screens/tools/advanced/layout_designer_screen.dart';
import 'package:inkwise_pdf/screens/tools/advanced/color_converter_screen.dart';
import 'package:inkwise_pdf/screens/tools/advanced/dual_page_view_screen.dart';
import 'package:inkwise_pdf/screens/tools/advanced/custom_stamps_screen.dart';
import 'package:inkwise_pdf/screens/tools/advanced/version_history_screen.dart';
import 'package:inkwise_pdf/screens/tools/advanced/pdf_indexer_screen.dart';
import 'package:inkwise_pdf/screens/tools/advanced/auto_tagging_screen.dart';
import 'package:inkwise_pdf/screens/tools/advanced/batch_tool_chain_screen.dart';
import 'package:inkwise_pdf/screens/tools/security/password_protection_screen.dart';
import 'package:inkwise_pdf/screens/tools/security/encryption_screen.dart';
import 'package:inkwise_pdf/screens/tools/security/secure_vault_screen.dart';

class AdvancedToolsScreen extends StatefulWidget {
  const AdvancedToolsScreen({super.key});

  @override
  State<AdvancedToolsScreen> createState() => _AdvancedToolsScreenState();
}

class _AdvancedToolsScreenState extends State<AdvancedToolsScreen>
    with TickerProviderStateMixin {
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
        title: const Text("Advanced Tools"),
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
              _buildLayoutTools(),
              const SizedBox(height: 24),
              _buildSecurityTools(),
              const SizedBox(height: 24),
              _buildFileManagementTools(),
              const SizedBox(height: 24),
              _buildAnalyticsTools(),
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
            AppColors.primaryBlue.withValues(alpha: 0.1),
            AppColors.primaryGreen.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.settings,
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
                  "Advanced PDF Tools",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Professional-grade tools for advanced document editing and analysis",
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
          "Featured Advanced Tools",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              FeaturedToolCard(
                title: "Table Extractor",
                subtitle: "Convert PDF tables to editable format",
                icon: Icons.table_chart,
                gradient: const LinearGradient(
                  colors: [AppColors.primaryGreen, AppColors.primaryBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TableExtractorScreen()),
                ),
              ),
              const SizedBox(width: 16),
              FeaturedToolCard(
                title: "Layout Designer",
                subtitle: "Rebuild page layouts visually",
                icon: Icons.design_services,
                gradient: const LinearGradient(
                  colors: [AppColors.primaryPurple, AppColors.primaryOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LayoutDesignerScreen()),
                ),
              ),
              const SizedBox(width: 16),
              FeaturedToolCard(
                title: "PDF Indexer",
                subtitle: "Instant search across all documents",
                icon: Icons.search,
                gradient: const LinearGradient(
                  colors: [AppColors.primaryBlue, AppColors.primaryGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PDFIndexerScreen()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLayoutTools() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Layout & Design Tools",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        StaggeredGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            ToolCard(
              title: "Table Extractor",
              icon: Icons.table_chart,
              color: AppColors.primaryGreen,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const TableExtractorScreen()),
              ),
            ),
            ToolCard(
              title: "Layout Designer",
              icon: Icons.design_services,
              color: AppColors.primaryPurple,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const LayoutDesignerScreen()),
              ),
            ),
            ToolCard(
              title: "Color Converter",
              icon: Icons.palette,
              color: AppColors.primaryOrange,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ColorConverterScreen()),
              ),
            ),
            ToolCard(
              title: "Dual Page View",
              icon: Icons.view_column,
              color: AppColors.primaryBlue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const DualPageViewScreen()),
              ),
            ),
            ToolCard(
              title: "Custom Stamps",
              icon: Icons.assignment,
              color: AppColors.primaryRed,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CustomStampsScreen()),
              ),
            ),
            ToolCard(
              title: "Version History",
              icon: Icons.history,
              color: AppColors.primaryGreen,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const VersionHistoryScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecurityTools() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Security & Encryption",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        StaggeredGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            ToolCard(
              title: "Password Protection",
              icon: Icons.lock,
              color: AppColors.primaryRed,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PasswordProtectionScreen()),
              ),
            ),
            ToolCard(
              title: "Encryption",
              icon: Icons.security,
              color: AppColors.primaryOrange,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EncryptionScreen()),
              ),
            ),
            ToolCard(
              title: "Secure Vault",
              icon: Icons.security,
              color: AppColors.primaryPurple,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SecureVaultScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFileManagementTools() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "File Management",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        StaggeredGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            ToolCard(
              title: "PDF Indexer",
              icon: Icons.search,
              color: AppColors.primaryBlue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PDFIndexerScreen()),
              ),
            ),
            ToolCard(
              title: "Auto Tagging",
              icon: Icons.label,
              color: AppColors.primaryGreen,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AutoTaggingScreen()),
              ),
            ),
            ToolCard(
              title: "Batch Tool Chain",
              icon: Icons.auto_fix_high,
              color: AppColors.primaryPurple,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const BatchToolChainScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalyticsTools() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Analytics & Insights",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryGreen.withValues(alpha: 0.1),
                AppColors.primaryBlue.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryGreen.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.analytics,
                      color: AppColors.primaryGreen,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Document Analytics",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "Get insights into your PDF documents including word frequency, reading time estimates, and document complexity analysis.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AdvancedToolsScreen()),
                  );
                },
                icon: const Icon(Icons.analytics),
                label: const Text("View Analytics"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
