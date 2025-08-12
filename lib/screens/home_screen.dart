import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../theme.dart';
import '../widgets/tool_card.dart';
import '../widgets/featured_tool_card.dart';
import '../services/local_analytics_service.dart';
import '../services/performance_service.dart';
import 'tools_screen.dart';
import 'recent_files_screen.dart';
import 'ai_tools_screen.dart';
import 'advanced_tools_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800), // Faster animation
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600), // Faster animation
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    
    // Start animations immediately for faster perceived performance
    _animationController.forward();
    _slideController.forward();
    
    // Preload essential data for faster navigation
    _preloadData();
    
    // Log screen view with local analytics
    LocalAnalyticsService().logScreenView('home_screen');
  }

  // Preload essential data for faster performance
  Future<void> _preloadData() async {
    // Preload tool data in background
    await Future.microtask(() {
      // Warm up tool lists and search data
      _performSearch('');
    });
    
    // Preload common services
    await Future.microtask(() {
      PerformanceService().getPerformanceStats();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildModernAppBar(),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWelcomeSection(),
                        const SizedBox(height: AppSpacing.xl),
                        _buildFeaturedSection(),
                        const SizedBox(height: AppSpacing.xl),
                        _buildQuickActions(),
                        const SizedBox(height: AppSpacing.xl),
                        _buildToolCategories(),
                        const SizedBox(height: AppSpacing.xl),
                        _buildRecentFilesSection(),
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      flexibleSpace: FlexibleSpaceBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              "Inkwise PDF",
              style: AppTypography.headlineMedium.copyWith(
                fontWeight: FontWeight.w700,
                background: Paint()
                  ..shader = const LinearGradient(
                    colors: [AppColors.gradientStart, AppColors.gradientEnd],
                  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
              ),
            ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.gradientStart.withOpacity(0.05),
                AppColors.gradientEnd.withOpacity(0.02),
              ],
            ),
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.glassLight,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: AppColors.textSecondaryLight.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.search, size: 20),
            onPressed: _showSearchDialog,
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: AppColors.textPrimaryLight,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.glassLight,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: AppColors.textSecondaryLight.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.settings, size: 20),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: AppColors.textPrimaryLight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.gradientStart.withOpacity(0.1),
            AppColors.gradientEnd.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColors.gradientStart.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.gradientStart, AppColors.gradientEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gradientStart.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome to Inkwise PDF",
                      style: AppTypography.headlineMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      "Professional PDF editing with AI-powered tools",
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _buildStatCard("25+", "Professional Tools", AppColors.primaryBlue),
              const SizedBox(width: AppSpacing.md),
              _buildStatCard("AI", "Powered", AppColors.primaryPurple),
              const SizedBox(width: AppSpacing.md),
              _buildStatCard("100%", "Offline", AppColors.primaryGreen),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Featured Tools",
          style: AppTypography.headlineMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              FeaturedToolCard(
                title: "AI Summarizer",
                subtitle: "Extract key insights from documents",
                icon: Icons.auto_awesome,
                gradient: const LinearGradient(
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AIToolsScreen()),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              FeaturedToolCard(
                title: "Smart Translator",
                subtitle: "Translate documents offline",
                icon: Icons.translate,
                gradient: const LinearGradient(
                  colors: [AppColors.primaryTeal, AppColors.primaryIndigo],
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AIToolsScreen()),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              FeaturedToolCard(
                title: "Advanced Tools",
                subtitle: "Professional PDF editing suite",
                icon: Icons.tune,
                gradient: const LinearGradient(
                  colors: [AppColors.primaryOrange, AppColors.primaryRed],
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdvancedToolsScreen()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Actions",
          style: AppTypography.headlineMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        StaggeredGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          children: [
            ToolCard(
              title: "Merge PDFs",
              icon: Icons.merge,
              color: AppColors.primaryBlue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ToolsScreen()),
              ),
            ),
            ToolCard(
              title: "Split PDF",
              icon: Icons.content_cut,
              color: AppColors.primaryGreen,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ToolsScreen()),
              ),
            ),
            ToolCard(
              title: "Compress",
              icon: Icons.compress,
              color: AppColors.primaryOrange,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ToolsScreen()),
              ),
            ),
            ToolCard(
              title: "Add Password",
              icon: Icons.lock,
              color: AppColors.primaryRed,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ToolsScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToolCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tool Categories",
          style: AppTypography.headlineMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        StaggeredGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          children: [
            _buildCategoryCard(
              "Core Tools",
              "Essential PDF operations",
              Icons.build,
              AppColors.primaryBlue,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ToolsScreen()),
              ),
            ),
            _buildCategoryCard(
              "AI Tools",
              "Smart AI-powered features",
              Icons.psychology,
              AppColors.primaryPurple,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AIToolsScreen()),
              ),
            ),
            _buildCategoryCard(
              "Advanced",
              "Professional features",
              Icons.tune,
              AppColors.primaryOrange,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdvancedToolsScreen()),
              ),
            ),
            _buildCategoryCard(
              "Security",
              "Protect your documents",
              Icons.security,
              AppColors.primaryRed,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ToolsScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentFilesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Recent Files",
              style: AppTypography.headlineMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
            ),
            TextButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RecentFilesScreen()),
              ),
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text("View All"),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: AppColors.textSecondaryLight.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    Icons.folder_open,
                    size: 32,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  "No recent files",
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSearchDialog() {
    String searchQuery = '';
    List<Map<String, dynamic>> searchResults = [];
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.gradientStart, AppColors.gradientEnd],
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    "Search Tools",
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Search for tools",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                        searchResults = _performSearch(value);
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (searchQuery.isNotEmpty) ...[
                    if (searchResults.isEmpty)
                      Text(
                        "No tools found",
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                      )
                    else
                      Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            final result = searchResults[index];
                            return ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                ),
                                child: Icon(
                                  result['icon'],
                                  color: AppColors.primaryBlue,
                                  size: 16,
                                ),
                              ),
                              title: Text(
                                result['title'],
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                result['subtitle'],
                                style: AppTypography.labelMedium.copyWith(
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                                _navigateToTool(result['route']);
                              },
                            );
                          },
                        ),
                      ),
                  ] else
                    Text(
                      "Search for tools and features",
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Close"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _performSearch(String query) {
    if (query.isEmpty) return [];
    
    final allTools = [
      // Core PDF Tools
      {'title': 'Merge PDFs', 'subtitle': 'Combine multiple PDF files', 'icon': Icons.merge, 'route': '/tools/merge'},
      {'title': 'Split PDF', 'subtitle': 'Divide PDF into separate files', 'icon': Icons.content_cut, 'route': '/tools/split'},
      {'title': 'Compress PDF', 'subtitle': 'Reduce PDF file size', 'icon': Icons.compress, 'route': '/tools/compress'},
      {'title': 'Rotate PDF', 'subtitle': 'Rotate page orientation', 'icon': Icons.rotate_right, 'route': '/tools/rotate'},
      {'title': 'PDF OCR', 'subtitle': 'Extract text from scanned documents', 'icon': Icons.text_fields, 'route': '/tools/ocr'},
      {'title': 'Add Password', 'subtitle': 'Protect PDF with password', 'icon': Icons.lock, 'route': '/tools/password'},
      {'title': 'Add Watermark', 'subtitle': 'Add text or image watermarks', 'icon': Icons.water_drop, 'route': '/tools/watermark'},
      {'title': 'PDF to Images', 'subtitle': 'Convert PDF pages to images', 'icon': Icons.image, 'route': '/tools/images'},
      {'title': 'Grayscale PDF', 'subtitle': 'Convert to black and white', 'icon': Icons.filter_b_and_w, 'route': '/tools/grayscale'},
      
      // AI Tools
      {'title': 'Smart Summarizer', 'subtitle': 'Extract key insights from documents', 'icon': Icons.auto_awesome, 'route': '/ai/summarizer'},
      {'title': 'Offline Translator', 'subtitle': 'Translate documents offline', 'icon': Icons.translate, 'route': '/ai/translator'},
      {'title': 'Voice to Text', 'subtitle': 'Convert speech to text notes', 'icon': Icons.mic, 'route': '/ai/voice'},
      {'title': 'Form Detector', 'subtitle': 'Detect and fill form fields', 'icon': Icons.assignment, 'route': '/ai/form'},
      {'title': 'Redaction Tool', 'subtitle': 'Remove sensitive information', 'icon': Icons.block, 'route': '/ai/redaction'},
      {'title': 'Keyword Analytics', 'subtitle': 'Analyze document keywords and frequency', 'icon': Icons.analytics, 'route': '/ai/analytics'},
      {'title': 'Handwriting Recognition', 'subtitle': 'Convert handwritten text to digital', 'icon': Icons.edit, 'route': '/ai/handwriting'},
      {'title': 'Content Cleanup', 'subtitle': 'Clean and enhance document content', 'icon': Icons.cleaning_services, 'route': '/ai/cleanup'},
      
      // Advanced Tools
      {'title': 'Layout Designer', 'subtitle': 'Design custom page layouts', 'icon': Icons.design_services, 'route': '/advanced/layout'},
      {'title': 'Color Converter', 'subtitle': 'Convert colors with threshold control', 'icon': Icons.palette, 'route': '/advanced/color'},
      {'title': 'Dual Page View', 'subtitle': 'View two pages side by side', 'icon': Icons.view_column, 'route': '/advanced/dual'},
      {'title': 'Custom Stamps', 'subtitle': 'Add custom stamps to documents', 'icon': Icons.stamp, 'route': '/advanced/stamps'},
      {'title': 'Version History', 'subtitle': 'Track document versions', 'icon': Icons.history, 'route': '/advanced/version'},
      {'title': 'PDF Indexer', 'subtitle': 'Index and search documents', 'icon': Icons.search, 'route': '/advanced/indexer'},
      {'title': 'Auto Tagging', 'subtitle': 'Automatically tag documents', 'icon': Icons.local_offer, 'route': '/advanced/tagging'},
      {'title': 'Batch Tool Chain', 'subtitle': 'Process multiple files efficiently', 'icon': Icons.settings_suggest, 'route': '/advanced/batch'},
      {'title': 'Table Extractor', 'subtitle': 'Extract tables from documents', 'icon': Icons.table_chart, 'route': '/advanced/table'},
    ];
    
    return allTools.where((tool) {
      return tool['title'].toString().toLowerCase().contains(query.toLowerCase()) ||
             tool['subtitle'].toString().toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  void _navigateToTool(String route) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected: $route'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }
}

