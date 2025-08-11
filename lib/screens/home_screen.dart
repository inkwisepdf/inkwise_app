import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../theme.dart';
import '../widgets/tool_card.dart';
import '../widgets/featured_tool_card.dart';
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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Theme.of(context).colorScheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                "Inkwise PDF",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryBlue.withOpacity(0.1),
                      AppColors.secondaryBlue.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  _showSearchDialog();
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),
            ],
          ),
          
          // Main Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Section
                      _buildWelcomeSection(),
                      const SizedBox(height: 24),
                      
                      // Featured AI Tools
                      _buildFeaturedSection(),
                      const SizedBox(height: 24),
                      
                      // Quick Actions
                      _buildQuickActions(),
                      const SizedBox(height: 24),
                      
                      // Tool Categories
                      _buildToolCategories(),
                      const SizedBox(height: 24),
                      
                      // Recent Files
                      _buildRecentFilesSection(),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue.withOpacity(0.1),
            AppColors.secondaryBlue.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.2),
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
              Icons.auto_awesome,
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
                  "Welcome to Inkwise PDF",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Your all-in-one offline PDF solution with AI-powered features",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection() {
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
                subtitle: "AI-powered document summarization",
                icon: Icons.summarize,
                gradient: [AppColors.primaryPurple, AppColors.primaryBlue],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AIToolsScreen()),
                ),
              ),
              const SizedBox(width: 16),
              FeaturedToolCard(
                title: "Offline Translator",
                subtitle: "Translate PDFs without internet",
                icon: Icons.translate,
                gradient: [AppColors.primaryGreen, AppColors.primaryBlue],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AIToolsScreen()),
                ),
              ),
              const SizedBox(width: 16),
              FeaturedToolCard(
                title: "Voice-to-Text Notes",
                subtitle: "Record and embed voice annotations",
                icon: Icons.mic,
                gradient: [AppColors.primaryOrange, AppColors.primaryRed],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AIToolsScreen()),
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
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        StaggeredGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            ToolCard(
              title: "Merge PDFs",
              icon: Icons.merge_type,
              color: AppColors.primaryBlue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ToolsScreen()),
              ),
            ),
            ToolCard(
              title: "Compress PDF",
              icon: Icons.compress,
              color: AppColors.primaryGreen,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ToolsScreen()),
              ),
            ),
            ToolCard(
              title: "OCR Tool",
              icon: Icons.text_snippet,
              color: AppColors.primaryPurple,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ToolsScreen()),
              ),
            ),
            ToolCard(
              title: "Split PDF",
              icon: Icons.content_cut,
              color: AppColors.primaryOrange,
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
          "Advanced Tools",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        StaggeredGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            ToolCard(
              title: "AI Tools",
              icon: Icons.psychology,
              color: AppColors.primaryPurple,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AIToolsScreen()),
              ),
            ),
            ToolCard(
              title: "Advanced Editing",
              icon: Icons.edit_note,
              color: AppColors.primaryBlue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdvancedToolsScreen()),
              ),
            ),
            ToolCard(
              title: "Security Tools",
              icon: Icons.security,
              color: AppColors.primaryRed,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdvancedToolsScreen()),
              ),
            ),
            ToolCard(
              title: "Analytics",
              icon: Icons.analytics,
              color: AppColors.primaryGreen,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdvancedToolsScreen()),
              ),
            ),
          ],
        ),
      ],
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
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RecentFilesScreen()),
              ),
              child: const Text("View All"),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_open,
                  size: 48,
                  color: AppColors.textSecondaryLight,
                ),
                SizedBox(height: 8),
                Text(
                  "No recent files",
                  style: TextStyle(
                    color: AppColors.textSecondaryLight,
                    fontSize: 16,
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Search Tools"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  hintText: "Search for tools...",
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  // TODO: Implement search functionality
                },
              ),
              const SizedBox(height: 16),
              const Text(
                "Search functionality coming soon!",
                style: TextStyle(
                  color: AppColors.textSecondaryLight,
                  fontSize: 14,
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
  }
}
