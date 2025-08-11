import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme.dart';
import '../services/performance_service.dart';
import '../services/image_optimization_service.dart';

class PerformanceMonitorScreen extends StatefulWidget {
  const PerformanceMonitorScreen({super.key});

  @override
  State<PerformanceMonitorScreen> createState() => _PerformanceMonitorScreenState();
}

class _PerformanceMonitorScreenState extends State<PerformanceMonitorScreen> {
  Map<String, dynamic> _performanceStats = {};
  Map<String, dynamic> _imageCacheStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPerformanceData();
  }

  Future<void> _loadPerformanceData() async {
    setState(() {
      _isLoading = true;
    });

    // Get performance statistics
    final performanceStats = PerformanceService().getPerformanceStats();
    final imageCacheStats = ImageOptimizationService().getCacheStats();

    setState(() {
      _performanceStats = performanceStats;
      _imageCacheStats = imageCacheStats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Performance Monitor"),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPerformanceData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildPerformanceOverview(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildOperationPerformance(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildCachePerformance(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildOptimizationSuggestions(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.gradientStart.withOpacity(0.1),
            AppColors.gradientEnd.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.gradientStart.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.gradientStart, AppColors.gradientEnd],
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.speed,
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
                  "Performance Monitor",
                  style: AppTypography.headlineMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  "Real-time performance metrics and optimization",
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceOverview() {
    final totalOperations = _performanceStats.values.fold<int>(
      0,
      (sum, operation) => sum + (operation['count'] as int),
    );

    final averageResponseTime = totalOperations > 0
        ? _performanceStats.values.fold<double>(
            0,
            (sum, operation) => sum + (operation['average'] as double),
          ) / _performanceStats.length
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Performance Overview",
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                "Total Operations",
                totalOperations.toString(),
                Icons.analytics,
                AppColors.primaryBlue,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildStatCard(
                "Avg Response Time",
                "${averageResponseTime.toStringAsFixed(1)}ms",
                Icons.timer,
                AppColors.primaryGreen,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOperationPerformance() {
    if (_performanceStats.isEmpty) {
      return _buildEmptyState("No performance data available");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Operation Performance",
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          height: 300,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: AppColors.textSecondaryLight.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: _getMaxResponseTime(),
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final operations = _performanceStats.keys.toList();
                      if (value.toInt() < operations.length) {
                        return Text(
                          operations[value.toInt()].split('_').last,
                          style: AppTypography.labelSmall,
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        "${value.toInt()}ms",
                        style: AppTypography.labelSmall,
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: _buildBarGroups(),
            ),
          ),
        ),
      ],
    );
  }

  double _getMaxResponseTime() {
    if (_performanceStats.isEmpty) return 100;
    return _performanceStats.values
        .map((operation) => operation['max'] as double)
        .reduce((a, b) => a > b ? a : b);
  }

  List<BarChartGroupData> _buildBarGroups() {
    final operations = _performanceStats.entries.toList();
    return operations.asMap().entries.map((entry) {
      final index = entry.key;
      final operation = entry.value;
      final average = operation['average'] as double;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: average,
            color: _getOperationColor(operation['operation'] as String),
            width: 20,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ],
      );
    }).toList();
  }

  Color _getOperationColor(String operation) {
    switch (operation) {
      case 'pdf_merge':
        return AppColors.primaryBlue;
      case 'pdf_split':
        return AppColors.primaryGreen;
      case 'pdf_compress':
        return AppColors.primaryOrange;
      case 'file_read':
        return AppColors.primaryPurple;
      default:
        return AppColors.primaryBlue;
    }
  }

  Widget _buildCachePerformance() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Cache Performance",
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildCacheCard(
                "Image Cache",
                "${_imageCacheStats['size'] ?? 0}/${_imageCacheStats['maxSize'] ?? 0}",
                "${(_imageCacheStats['memoryUsage'] ?? 0) ~/ 1024}KB",
                Icons.image,
                AppColors.primaryGreen,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildCacheCard(
                "Memory Cache",
                "Active",
                "Optimized",
                Icons.memory,
                AppColors.primaryBlue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCacheCard(String title, String usage, String memory, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            usage,
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            memory,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptimizationSuggestions() {
    final suggestions = _generateOptimizationSuggestions();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Optimization Suggestions",
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...suggestions.map((suggestion) => _buildSuggestionCard(suggestion)),
      ],
    );
  }

  List<Map<String, dynamic>> _generateOptimizationSuggestions() {
    final suggestions = <Map<String, dynamic>>[];

    // Check for slow operations
    _performanceStats.forEach((operation, stats) {
      final average = stats['average'] as double;
      if (average > 1000) {
        suggestions.add({
          'title': 'Slow Operation Detected',
          'description': '$operation is taking ${average.toStringAsFixed(0)}ms on average',
          'icon': Icons.warning,
          'color': AppColors.primaryOrange,
          'priority': 'High',
        });
      }
    });

    // Check cache efficiency
    final imageCacheSize = _imageCacheStats['size'] ?? 0;
    final maxImageCacheSize = _imageCacheStats['maxSize'] ?? 50;
    if (imageCacheSize < maxImageCacheSize * 0.3) {
      suggestions.add({
        'title': 'Cache Underutilized',
        'description': 'Image cache is only ${(imageCacheSize / maxImageCacheSize * 100).toStringAsFixed(0)}% full',
        'icon': Icons.info,
        'color': AppColors.primaryBlue,
        'priority': 'Medium',
      });
    }

    // Add general optimization tips
    suggestions.add({
      'title': 'Performance Optimized',
      'description': 'App is running with optimized performance settings',
      'icon': Icons.check_circle,
      'color': AppColors.primaryGreen,
      'priority': 'Info',
    });

    return suggestions;
  }

  Widget _buildSuggestionCard(Map<String, dynamic> suggestion) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: (suggestion['color'] as Color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: (suggestion['color'] as Color).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            suggestion['icon'] as IconData,
            color: suggestion['color'] as Color,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestion['title'] as String,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  suggestion['description'] as String,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: (suggestion['color'] as Color).withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              suggestion['priority'] as String,
              style: AppTypography.labelSmall.copyWith(
                color: suggestion['color'] as Color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: AppColors.textSecondaryLight,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}