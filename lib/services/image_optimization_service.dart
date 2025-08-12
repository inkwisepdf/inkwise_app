import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;

class ImageOptimizationService {
  static final ImageOptimizationService _instance = ImageOptimizationService._internal();
  factory ImageOptimizationService() => _instance;
  ImageOptimizationService._internal();

  // Image processing cache
  final Map<String, Uint8List> _imageCache = {};
  static const int _maxCacheSize = 50;

  // Optimized image processing with caching
  Future<Uint8List> optimizeImage(Uint8List imageData, {
    int? maxWidth,
    int? maxHeight,
    double quality = 0.8,
    bool maintainAspectRatio = true,
  }) async {
    final cacheKey = _generateCacheKey(imageData, maxWidth, maxHeight, quality);
    
    // Check cache first
    if (_imageCache.containsKey(cacheKey)) {
      return _imageCache[cacheKey]!;
    }

    return await compute(_processImageOptimization, {
      'imageData': imageData,
      'maxWidth': maxWidth,
      'maxHeight': maxHeight,
      'quality': quality,
      'maintainAspectRatio': maintainAspectRatio,
    }).then((result) {
      // Cache the result
      _addToCache(cacheKey, result);
      return result;
    });
  }

  // Process image optimization in isolate
  static Future<Uint8List> _processImageOptimization(Map<String, dynamic> params) async {
    final Uint8List imageData = params['imageData'];
    final int? maxWidth = params['maxWidth'];
    final int? maxHeight = params['maxHeight'];
    final double quality = params['quality'];
    final bool maintainAspectRatio = params['maintainAspectRatio'];

    // Decode image
    final img.Image? image = img.decodeImage(imageData);
    if (image == null) return imageData;

    img.Image processedImage = image;

    // Resize if needed
    if (maxWidth != null || maxHeight != null) {
      processedImage = _resizeImage(image, maxWidth, maxHeight, maintainAspectRatio);
    }

    // Optimize quality
    if (quality < 1.0) {
      processedImage = _optimizeQuality(processedImage, quality);
    }

    // Encode with optimization
    return Uint8List.fromList(img.encodeJpg(processedImage, quality: (quality * 100).round()));
  }

  // Resize image with aspect ratio preservation
  static img.Image _resizeImage(
    img.Image image,
    int? maxWidth,
    int? maxHeight,
    bool maintainAspectRatio,
  ) {
    int targetWidth = image.width;
    int targetHeight = image.height;

    if (maxWidth != null && image.width > maxWidth) {
      targetWidth = maxWidth;
      if (maintainAspectRatio) {
        targetHeight = (image.height * maxWidth / image.width).round();
      }
    }

    if (maxHeight != null && targetHeight > maxHeight) {
      targetHeight = maxHeight;
      if (maintainAspectRatio) {
        targetWidth = (targetWidth * maxHeight / targetHeight).round();
      }
    }

    return img.copyResize(image, width: targetWidth, height: targetHeight);
  }

  // Optimize image quality
  static img.Image _optimizeQuality(img.Image image, double quality) {
    // Apply quality optimization techniques
    if (quality < 0.7) {
      // Reduce color depth for lower quality
      return img.quantize(image, numberOfColors: 256);
    }
    return image;
  }

  // Generate cache key
  String _generateCacheKey(Uint8List imageData, int? maxWidth, int? maxHeight, double quality) {
    final hash = imageData.length + (maxWidth ?? 0) + (maxHeight ?? 0) + (quality * 100).round();
    return 'img_${hash}_${imageData.length}';
  }

  // Add to cache with LRU eviction
  void _addToCache(String key, Uint8List data) {
    if (_imageCache.length >= _maxCacheSize) {
      // Remove oldest entry (simple FIFO for performance)
      final oldestKey = _imageCache.keys.first;
      _imageCache.remove(oldestKey);
    }
    _imageCache[key] = data;
  }

  // Batch image processing for multiple images
  Future<List<Uint8List>> optimizeImagesBatch(
    List<Uint8List> imageDataList, {
    int? maxWidth,
    int? maxHeight,
    double quality = 0.8,
  }) async {
    final futures = imageDataList.map((imageData) => 
      optimizeImage(imageData, maxWidth: maxWidth, maxHeight: maxHeight, quality: quality)
    );
    
    return await Future.wait(futures);
  }

  // Fast thumbnail generation
  Future<Uint8List> generateThumbnail(Uint8List imageData, {int size = 200}) async {
    return await optimizeImage(
      imageData,
      maxWidth: size,
      maxHeight: size,
      quality: 0.6,
      maintainAspectRatio: true,
    );
  }

  // Clear cache
  void clearCache() {
    _imageCache.clear();
  }

  // Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'size': _imageCache.length,
      'maxSize': _maxCacheSize,
      'memoryUsage': _imageCache.values.fold<int>(0, (sum, data) => sum + data.length),
    };
  }
}
