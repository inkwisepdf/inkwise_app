import 'package:flutter/material.dart';
import 'package:inkwise_pdf/theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'dart:math';

class PerformanceMonitorScreen extends StatefulWidget {
  const PerformanceMonitorScreen({super.key});

  @override
  State<PerformanceMonitorScreen> createState() => _PerformanceMonitorScreenState();
}

class _PerformanceMonitorScreenState extends State<PerformanceMonitorScreen>
    with TickerProviderStateMixin {
  late Timer _updateTimer;
  late AnimationController _cpuController;
  late AnimationController _memoryController;
  late AnimationController _batteryController;

  // Performance data
  double _cpuUsage = 0.0;
  double _memoryUsage = 0.0;
  double _batteryLevel = 0.0;
  double _temperature = 0.0;
  int _fps = 0;
  int _activeConnections = 0;

  // Historical data for charts
  final List<FlSpot> _cpuHistory = [];
  final List<FlSpot> _memoryHistory = [];
  final List<FlSpot> _fpsHistory = [];
  final List<FlSpot> _batteryHistory = [];

  // Chart data
  final List<BarChartGroupData> _performanceBars = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _startMonitoring();
    _generateChartData();
  }

  void _initializeControllers() {
    _cpuController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _memoryController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _batteryController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  void _startMonitoring() {
    _updateTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _updatePerformanceData();
    });
  }

  void _updatePerformanceData() {
    setState(() {
      // Simulate performance data updates
      _cpuUsage = _generateRandomValue(20.0, 80.0);
      _memoryUsage = _generateRandomValue(30.0, 90.0);
      _batteryLevel = _generateRandomValue(10.0, 100.0);
      _temperature = _generateRandomValue(25.0, 45.0);
      _fps = _generateRandomValue(30, 60).round();
      _activeConnections = _generateRandomValue(5, 25).round();

      // Update historical data
      _updateHistoricalData();
    });

    // Animate controllers
    _cpuController.forward(from: 0.0);
    _memoryController.forward(from: 0.0);
    _batteryController.forward(from: 0.0);
  }

  double _generateRandomValue(double min, double max) {
    return min + Random().nextDouble() * (max - min);
  }

  void _updateHistoricalData() {
    final now = DateTime.now().millisecondsSinceEpoch.toDouble();
    
    _cpuHistory.add(FlSpot(now, _cpuUsage));
    _memoryHistory.add(FlSpot(now, _memoryUsage));
    _fpsHistory.add(FlSpot(now, _fps.toDouble()));
    _batteryHistory.add(FlSpot(now, _batteryLevel));

    // Keep only last 50 data points
    if (_cpuHistory.length > 50) {
      _cpuHistory.removeAt(0);
      _memoryHistory.removeAt(0);
      _fpsHistory.removeAt(0);
      _batteryHistory.removeAt(0);
    }
  }

  void _generateChartData() {
    _performanceBars.clear();
    for (int i = 0; i < 7; i++) {
      _performanceBars.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: _generateRandomValue(20, 90),
              color: AppColors.primaryPurple,
              width: 20,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _updateTimer.cancel();
    _cpuController.dispose();
    _memoryController.dispose();
    _batteryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Performance Monitor"),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildPerformanceCards(),
            const SizedBox(height: 24),
            _buildCharts(),
            const SizedBox(height: 24),
            _buildSystemInfo(),
          ],
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
            AppColors.primaryPurple.withOpacity(0.1),
            AppColors.primaryBlue.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryPurple.withOpacity(0.2),
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
              Icons.speed,
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
                  "Real-time Performance Monitoring",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Monitor CPU, memory, battery, and system performance in real-time",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildPerformanceCard(
          title: "CPU Usage",
          value: "${_cpuUsage.toStringAsFixed(1)}%",
          icon: Icons.memory,
          color: AppColors.primaryPurple,
          controller: _cpuController,
          progress: _cpuUsage / 100,
        ),
        _buildPerformanceCard(
          title: "Memory Usage",
          value: "${_memoryUsage.toStringAsFixed(1)}%",
          icon: Icons.storage,
          color: AppColors.primaryBlue,
          controller: _cpuController,
          progress: _memoryUsage / 100,
        ),
        _buildPerformanceCard(
          title: "Battery Level",
          value: "${_batteryLevel.toStringAsFixed(1)}%",
          icon: Icons.battery_full,
          color: AppColors.success,
          controller: _batteryController,
          progress: _batteryLevel / 100,
        ),
        _buildPerformanceCard(
          title: "FPS",
          value: "$_fps",
          icon: Icons.video_library,
          color: AppColors.warning,
          controller: _cpuController,
          progress: _fps / 60,
        ),
      ],
    );
  }

  Widget _buildPerformanceCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required AnimationController controller,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildCharts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Performance Trends",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderLight,
            ),
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                horizontalInterval: 20,
                verticalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: AppColors.borderLight,
                    strokeWidth: 1,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: AppColors.borderLight,
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(
                  
                ),
                topTitles: const AxisTitles(
                  
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          "${value.toInt()}s",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 20,
                    reservedSize: 42,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        "${value.toInt()}%",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: AppColors.borderLight),
              ),
              minX: 0,
              maxX: 50,
              minY: 0,
              maxY: 100,
              lineBarsData: [
                LineChartBarData(
                  spots: _cpuHistory,
                  isCurved: true,
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primaryPurple,
                      AppColors.primaryBlue,
                    ],
                  ),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryPurple.withOpacity(0.3),
                        AppColors.primaryBlue.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
                LineChartBarData(
                  spots: _memoryHistory,
                  isCurved: true,
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.success,
                      AppColors.warning,
                    ],
                  ),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.success.withOpacity(0.3),
                        AppColors.warning.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: AppColors.surfaceLight,
                  tooltipRoundedRadius: 8,
                  tooltipPadding: const EdgeInsets.all(8),
                  tooltipMargin: 8,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((touchedSpot) {
                      return LineTooltipItem(
                        "${touchedSpot.y.toStringAsFixed(1)}%",
                        TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderLight,
            ),
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 100,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(
                  
                ),
                topTitles: const AxisTitles(
                  
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          days[value.toInt()],
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 20,
                    reservedSize: 42,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        "${value.toInt()}%",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: AppColors.borderLight),
              ),
              barGroups: _performanceBars,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSystemInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "System Information",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow("Temperature", "${_temperature.toStringAsFixed(1)}°C", Icons.thermostat),
          _buildInfoRow("Active Connections", "$_activeConnections", Icons.wifi),
          _buildInfoRow("Last Update", DateTime.now().toString().substring(11, 19), Icons.access_time),
          _buildInfoRow("Status", "Monitoring", Icons.check_circle, color: AppColors.success),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: color ?? AppColors.primaryPurple,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color ?? AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}