import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalAnalyticsService {
  static Database? _database;
  static const String _analyticsTable = 'analytics_events';
  static const String _userActionsTable = 'user_actions';
  static const String _appUsageTable = 'app_usage';
  
  // Singleton pattern
  static final LocalAnalyticsService _instance = LocalAnalyticsService._internal();
  factory LocalAnalyticsService() => _instance;
  LocalAnalyticsService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'inkwise_analytics.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        // Analytics events table
        await db.execute('''
          CREATE TABLE $_analyticsTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            event_name TEXT NOT NULL,
            parameters TEXT,
            timestamp INTEGER NOT NULL,
            session_id TEXT,
            user_id TEXT
          )
        ''');

        // User actions table
        await db.execute('''
          CREATE TABLE $_userActionsTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            action_type TEXT NOT NULL,
            action_details TEXT,
            timestamp INTEGER NOT NULL,
            screen_name TEXT,
            duration INTEGER
          )
        ''');

        // App usage table
        await db.execute('''
          CREATE TABLE $_appUsageTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_start INTEGER NOT NULL,
            session_end INTEGER,
            screen_views TEXT,
            features_used TEXT,
            total_duration INTEGER
          )
        ''');
      },
    );
  }

  // Log analytics event
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    try {
      final db = await database;
      final sessionId = await _getCurrentSessionId();
      final userId = await _getUserId();
      
      await db.insert(_analyticsTable, {
        'event_name': name,
        'parameters': parameters != null ? jsonEncode(parameters) : null,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'session_id': sessionId,
        'user_id': userId,
      });

      // Also log to user actions for detailed tracking
      await logUserAction('analytics_event', {
        'event_name': name,
        'parameters': parameters,
      });
    } catch (e) {
      print('Error logging analytics event: $e');
    }
  }

  // Log screen view
  Future<void> logScreenView(String screenName) async {
    try {
      await logEvent('screen_view', {
        'screen_name': screenName,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      await logUserAction('screen_view', {
        'screen_name': screenName,
      });
    } catch (e) {
      print('Error logging screen view: $e');
    }
  }

  // Log user action
  Future<void> logUserAction(String actionType, {Map<String, dynamic>? details}) async {
    try {
      final db = await database;
      
      await db.insert(_userActionsTable, {
        'action_type': actionType,
        'action_details': details != null ? jsonEncode(details) : null,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'screen_name': await _getCurrentScreen(),
        'duration': 0, // Will be calculated when action completes
      });
    } catch (e) {
      print('Error logging user action: $e');
    }
  }

  // Start app session
  Future<void> startSession() async {
    try {
      final db = await database;
      final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
      
      await db.insert(_appUsageTable, {
        'session_start': DateTime.now().millisecondsSinceEpoch,
        'session_end': null,
        'screen_views': jsonEncode([]),
        'features_used': jsonEncode([]),
        'total_duration': 0,
      });

      // Store session ID in preferences
      await _setCurrentSessionId(sessionId);
    } catch (e) {
      print('Error starting session: $e');
    }
  }

  // End app session
  Future<void> endSession() async {
    try {
      final db = await database;
      final sessionId = await _getCurrentSessionId();
      
      if (sessionId != null) {
        await db.update(
          _appUsageTable,
          {
            'session_end': DateTime.now().millisecondsSinceEpoch,
          },
          where: 'session_start = ?',
          whereArgs: [int.parse(sessionId)],
        );
      }
    } catch (e) {
      print('Error ending session: $e');
    }
  }

  // Get analytics data
  Future<Map<String, dynamic>> getAnalyticsData({
    DateTime? startDate,
    DateTime? endDate,
    String? eventName,
  }) async {
    try {
      final db = await database;
      final startTimestamp = startDate?.millisecondsSinceEpoch ?? 0;
      final endTimestamp = endDate?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch;

      // Get event counts
      final eventCounts = await db.rawQuery('''
        SELECT event_name, COUNT(*) as count
        FROM $_analyticsTable
        WHERE timestamp BETWEEN ? AND ?
        ${eventName != null ? 'AND event_name = ?' : ''}
        GROUP BY event_name
        ORDER BY count DESC
      ''', eventName != null ? [startTimestamp, endTimestamp, eventName] : [startTimestamp, endTimestamp]);

      // Get screen view counts
      final screenViews = await db.rawQuery('''
        SELECT action_details, COUNT(*) as count
        FROM $_userActionsTable
        WHERE action_type = 'screen_view'
        AND timestamp BETWEEN ? AND ?
        GROUP BY action_details
        ORDER BY count DESC
      ''', [startTimestamp, endTimestamp]);

      // Get feature usage
      final featureUsage = await db.rawQuery('''
        SELECT action_type, COUNT(*) as count
        FROM $_userActionsTable
        WHERE timestamp BETWEEN ? AND ?
        AND action_type NOT IN ('screen_view', 'analytics_event')
        GROUP BY action_type
        ORDER BY count DESC
      ''', [startTimestamp, endTimestamp]);

      // Get session data
      final sessions = await db.rawQuery('''
        SELECT COUNT(*) as total_sessions,
               AVG(total_duration) as avg_session_duration
        FROM $_appUsageTable
        WHERE session_start BETWEEN ? AND ?
      ''', [startTimestamp, endTimestamp]);

      return {
        'event_counts': eventCounts,
        'screen_views': screenViews,
        'feature_usage': featureUsage,
        'sessions': sessions.isNotEmpty ? sessions.first : {},
        'period': {
          'start': startTimestamp,
          'end': endTimestamp,
        },
      };
    } catch (e) {
      print('Error getting analytics data: $e');
      return {};
    }
  }

  // Get usage statistics
  Future<Map<String, dynamic>> getUsageStatistics() async {
    try {
      final db = await database;
      
      // Total events
      final totalEvents = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $_analyticsTable')
      ) ?? 0;

      // Total sessions
      final totalSessions = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $_appUsageTable')
      ) ?? 0;

      // Most used features
      final topFeatures = await db.rawQuery('''
        SELECT action_type, COUNT(*) as count
        FROM $_userActionsTable
        WHERE action_type NOT IN ('screen_view', 'analytics_event')
        GROUP BY action_type
        ORDER BY count DESC
        LIMIT 10
      ''');

      // Most viewed screens
      final topScreens = await db.rawQuery('''
        SELECT action_details, COUNT(*) as count
        FROM $_userActionsTable
        WHERE action_type = 'screen_view'
        GROUP BY action_details
        ORDER BY count DESC
        LIMIT 10
      ''');

      // Recent activity
      final recentActivity = await db.rawQuery('''
        SELECT action_type, action_details, timestamp
        FROM $_userActionsTable
        ORDER BY timestamp DESC
        LIMIT 20
      ''');

      return {
        'total_events': totalEvents,
        'total_sessions': totalSessions,
        'top_features': topFeatures,
        'top_screens': topScreens,
        'recent_activity': recentActivity,
        'last_updated': DateTime.now().millisecondsSinceEpoch,
      };
    } catch (e) {
      print('Error getting usage statistics: $e');
      return {};
    }
  }

  // Export analytics data
  Future<String> exportAnalyticsData() async {
    try {
      final analyticsData = await getAnalyticsData();
      final usageStats = await getUsageStatistics();
      
      final exportData = {
        'export_date': DateTime.now().toIso8601String(),
        'analytics_data': analyticsData,
        'usage_statistics': usageStats,
      };

      return jsonEncode(exportData);
    } catch (e) {
      print('Error exporting analytics data: $e');
      return '{}';
    }
  }

  // Clear old analytics data (older than specified days)
  Future<void> clearOldData(int daysToKeep) async {
    try {
      final db = await database;
      final cutoffTime = DateTime.now().subtract(Duration(days: daysToKeep)).millisecondsSinceEpoch;
      
      await db.delete(_analyticsTable, where: 'timestamp < ?', whereArgs: [cutoffTime]);
      await db.delete(_userActionsTable, where: 'timestamp < ?', whereArgs: [cutoffTime]);
      await db.delete(_appUsageTable, where: 'session_start < ?', whereArgs: [cutoffTime]);
    } catch (e) {
      print('Error clearing old data: $e');
    }
  }

  // Helper methods for session and user management
  Future<String?> _getCurrentSessionId() async {
    // In a real implementation, you'd use SharedPreferences
    // For now, return a simple session ID
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<void> _setCurrentSessionId(String sessionId) async {
    // In a real implementation, you'd use SharedPreferences
    // For now, just store in memory
  }

  Future<String?> _getUserId() async {
    // In a real implementation, you'd get from local storage
    // For now, return a simple user ID
    return 'local_user_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<String?> _getCurrentScreen() async {
    // In a real implementation, you'd track current screen
    // For now, return a default
    return 'unknown_screen';
  }

  // Initialize analytics
  Future<void> initialize() async {
    try {
      await database; // Initialize database
      await startSession(); // Start first session
    } catch (e) {
      print('Error initializing analytics: $e');
    }
  }

  // Dispose analytics
  Future<void> dispose() async {
    try {
      await endSession();
      await _database?.close();
      _database = null;
    } catch (e) {
      print('Error disposing analytics: $e');
    }
  }
}