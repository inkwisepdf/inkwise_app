import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:hive/hive.dart';

class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  // Cache management
  final Map<String, dynamic> _memoryCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const int _maxCacheSize = 100; // Maximum items in memory cache
  static const Duration _cacheExpiry = Duration(minutes: 30);

  // Database for persistent caching
  Database? _cacheDatabase;
  static const String _cacheTable = 'performance_cache';

  // Performance monitoring
  final Map<String, Stopwatch> _operationTimers = {};
  final List<Map<String, dynamic>> _performanceLog = [];

  // File processing optimization
  static const int _maxConcurrentOperations = 4;
  final Semaphore _operationSemaphore = Semaphore(_maxConcurrentOperations);

  // Initialize performance service
  Future<void> initialize() async {
    await _initializeCacheDatabase();
    await _cleanupExpiredCache();
    _startPerformanceMonitoring();
  }

  // Initialize cache database
  Future<void> _initializeCacheDatabase() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final dbPath = path.join(documentsDir.path, 'performance_cache.db');

    _cacheDatabase = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $_cacheTable (
            key TEXT PRIMARY KEY,
            data TEXT,
            timestamp INTEGER,
            size INTEGER
          )
        ''');
      },
    );
  }

  // Memory cache operations
  T? getFromCache<T>(String key) {
    if (_memoryCache.containsKey(key)) {
      final timestamp = _cacheTimestamps[key];
      if (timestamp != null && DateTime.now().difference(timestamp) < _cacheExpiry) {
        return _memoryCache[key] as T?;
      } else {
        _memoryCache.remove(key);
        _cacheTimestamps.remove(key);
      }
    }
    return null;
  }

  void setCache<T>(String key, T value) {
    // Implement LRU cache eviction
    if (_memoryCache.length >= _maxCacheSize) {
      final oldestKey = _cacheTimestamps.entries
          .reduce((a, b) => a.value.isBefore(b.value) ? a : b)
          .key;
      _memoryCache.remove(oldestKey);
      _cacheTimestamps.remove(oldestKey);
    }

    _memoryCache[key] = value;
    _cacheTimestamps[key] = DateTime.now();
  }

  // Persistent cache operations
  Future<T?> getFromPersistentCache<T>(String key) async {
    if (_cacheDatabase == null) return null;

    final result = await _cacheDatabase!.query(
      _cacheTable,
      where: 'key = ?',
      whereArgs: [key],
    );

    if (result.isNotEmpty) {
      final timestamp = DateTime.fromMillisecondsSinceEpoch(result.first['timestamp'] as int);
      if (DateTime.now().difference(timestamp) < _cacheExpiry) {
        return result.first['data'] as T?;
      } else {
        await _cacheDatabase!.delete(
          _cacheTable,
          where: 'key = ?',
          whereArgs: [key],
        );
      }
    }
    return null;
  }

  Future<void> setPersistentCache<T>(String key, T value) async {
    if (_cacheDatabase == null) return;

    await _cacheDatabase!.insert(
      _cacheTable,
      {
        'key': key,
        'data': value.toString(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'size': value.toString().length,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Performance monitoring
  void startOperation(String operationName) {
    _operationTimers[operationName] = Stopwatch()..start();
  }

  void endOperation(String operationName) {
    final timer = _operationTimers[operationName];
    if (timer != null) {
      timer.stop();
      _performanceLog.add({
        'operation': operationName,
        'duration': timer.elapsedMilliseconds,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      _operationTimers.remove(operationName);
    }
  }

  // Get performance statistics
  Map<String, dynamic> getPerformanceStats() {
    if (_performanceLog.isEmpty) return {};

    final operations = <String, List<int>>{};
    for (final log in _performanceLog) {
      final operation = log['operation'] as String;
      final duration = log['duration'] as int;
      operations.putIfAbsent(operation, () => []).add(duration);
    }

    final stats = <String, dynamic>{};
    operations.forEach((operation, durations) {
      durations.sort();
      stats[operation] = {
        'count': durations.length,
        'average': durations.reduce((a, b) => a + b) / durations.length,
        'min': durations.first,
        'max': durations.last,
        'median': durations[durations.length ~/ 2],
      };
    });

    return stats;
  }

  // File processing optimization
  Future<T> withOperationLimit<T>(Future<T> Function() operation) async {
    return await _operationSemaphore.run(operation);
  }

  // Optimized file reading with caching
  Future<Uint8List> readFileOptimized(String filePath) async {
    final cacheKey = 'file_${path.basename(filePath)}_${await _getFileHash(filePath)}';
    
    // Check memory cache first
    final cachedData = getFromCache<Uint8List>(cacheKey);
    if (cachedData != null) return cachedData;

    // Check persistent cache
    final persistentData = await getFromPersistentCache<String>(cacheKey);
    if (persistentData != null) {
      final data = Uint8List.fromList(persistentData.codeUnits);
      setCache(cacheKey, data);
      return data;
    }

    // Read from file
    startOperation('file_read');
    final file = File(filePath);
    final data = await file.readAsBytes();
    endOperation('file_read');

    // Cache the result
    setCache(cacheKey, data);
    await setPersistentCache(cacheKey, String.fromCharCodes(data));

    return data;
  }

  // Get file hash for caching
  Future<String> _getFileHash(String filePath) async {
    final file = File(filePath);
    final stat = await file.stat();
    return '${stat.size}_${stat.modified.millisecondsSinceEpoch}';
  }

  // Cleanup expired cache
  Future<void> _cleanupExpiredCache() async {
    final now = DateTime.now();
    final expiredKeys = _cacheTimestamps.entries
        .where((entry) => now.difference(entry.value) >= _cacheExpiry)
        .map((entry) => entry.key)
        .toList();

    for (final key in expiredKeys) {
      _memoryCache.remove(key);
      _cacheTimestamps.remove(key);
    }

    if (_cacheDatabase != null) {
      final expiryTime = now.subtract(_cacheExpiry).millisecondsSinceEpoch;
      await _cacheDatabase!.delete(
        _cacheTable,
        where: 'timestamp < ?',
        whereArgs: [expiryTime],
      );
    }
  }

  // Start performance monitoring
  void _startPerformanceMonitoring() {
    Timer.periodic(const Duration(minutes: 5), (timer) {
      _cleanupExpiredCache();
      _logPerformanceStats();
    });
  }

  // Log performance statistics
  void _logPerformanceStats() {
    final stats = getPerformanceStats();
    if (stats.isNotEmpty) {
      debugPrint('Performance Stats: $stats');
    }
  }

  // Optimize image processing
  Future<Uint8List> optimizeImageProcessing(Uint8List imageData) async {
    startOperation('image_optimization');
    
    // Implement image optimization logic here
    // This is a placeholder for actual image optimization
    
    endOperation('image_optimization');
    return imageData;
  }

  // Optimize PDF processing
  Future<void> optimizePDFProcessing(String filePath) async {
    startOperation('pdf_optimization');
    
    // Implement PDF optimization logic here
    // This is a placeholder for actual PDF optimization
    
    endOperation('pdf_optimization');
  }

  // Memory management
  void clearMemoryCache() {
    _memoryCache.clear();
    _cacheTimestamps.clear();
  }

  Future<void> clearPersistentCache() async {
    if (_cacheDatabase != null) {
      await _cacheDatabase!.delete(_cacheTable);
    }
  }

  // Dispose resources
  Future<void> dispose() async {
    clearMemoryCache();
    await clearPersistentCache();
    await _cacheDatabase?.close();
  }
}

// Semaphore for limiting concurrent operations
class Semaphore {
  final int _maxCount;
  int _currentCount;
  final List<Completer<void>> _waiters = [];

  Semaphore(this._maxCount) : _currentCount = _maxCount;

  Future<T> run<T>(Future<T> Function() operation) async {
    await _acquire();
    try {
      return await operation();
    } finally {
      _release();
    }
  }

  Future<void> _acquire() async {
    if (_currentCount > 0) {
      _currentCount--;
      return;
    }

    final completer = Completer<void>();
    _waiters.add(completer);
    await completer.future;
  }

  void _release() {
    if (_waiters.isNotEmpty) {
      final waiter = _waiters.removeAt(0);
      waiter.complete();
    } else {
      _currentCount++;
    }
  }
}
