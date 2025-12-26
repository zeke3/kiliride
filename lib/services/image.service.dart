// // SOLUTION 1: Background Processing with Isolates
// import 'dart:io';
// import 'dart:isolate';
// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:waka/controllers/notification_handler.dart';

// class ImageProcessingService {
//   static Future<File> processImageInIsolate(File imageFile) async {
//     final receivePort = ReceivePort();

//     await Isolate.spawn(_processImageIsolate, {
//       'sendPort': receivePort.sendPort,
//       'imagePath': imageFile.path,
//     });

//     final result = await receivePort.first;
//     return File(result);
//   }

//   static void _processImageIsolate(Map<String, dynamic> args) async {
//     final SendPort sendPort = args['sendPort'];
//     final String imagePath = args['imagePath'];

//     try {
//       final file = File(imagePath);
//       final compressedFile = await _compressImageOptimized(file);
//       sendPort.send(compressedFile.path);
//     } catch (e) {
//       sendPort.send(imagePath); // Return original if compression fails
//     }
//   }
// }

// // SOLUTION 2: Progressive Quality Reduction
// Future<File> _compressImageProgressive(File imageFile) async {
//   final int originalSize = await imageFile.length();
//   const int targetSizeKB = 500; // Target 500KB

//   int quality = 85;
//   File? result;

//   while (quality >= 30) {
//     final compressed = await _compressSingleImage(imageFile, quality);
//     if (compressed != null) {
//       final size = await compressed.length();
//       if (size <= targetSizeKB * 1024 || quality <= 30) {
//         result = compressed;
//         break;
//       }
//     }
//     quality -= 15;
//   }

//   return result ?? imageFile;
// }

// // SOLUTION 3: Smart Compression Based on File Size
// Future<File> _optimizeImageSmart(File imageFile) async {
//   final int originalSize = await imageFile.length();
//   final double sizeInMB = originalSize / (1024 * 1024);

//   // Skip compression for already small images
//   if (sizeInMB <= 0.5) return imageFile;

//   int quality;
//   int maxDimension;

//   if (sizeInMB <= 2) {
//     quality = 80;
//     maxDimension = 1200;
//   } else if (sizeInMB <= 5) {
//     quality = 70;
//     maxDimension = 1000;
//   } else {
//     quality = 60;
//     maxDimension = 800;
//   }

//   return await _compressWithSettings(imageFile, quality, maxDimension);
// }

// // SOLUTION 4: Batch Processing with Progress Updates
// Future<List<File>> _processImagesWithProgress(
//   List<File> images,
//   Function(double progress) onProgress,
// ) async {
//   final List<File> processedImages = [];

//   for (int i = 0; i < images.length; i++) {
//     final processed = await _optimizeImageSmart(images[i]);
//     processedImages.add(processed);

//     // Update progress
//     final progress = (i + 1) / images.length;
//     onProgress(progress);
//   }

//   return processedImages;
// }

// // SOLUTION 5: Parallel Processing (Limited Concurrency)
// Future<List<File>> _processImagesParallel(List<File> images) async {
//   const int maxConcurrency = 2; // Process 2 images at once
//   final List<File> results = [];

//   for (int i = 0; i < images.length; i += maxConcurrency) {
//     final batch = images.skip(i).take(maxConcurrency).toList();
//     final futures = batch.map((image) => _optimizeImageSmart(image));
//     final batchResults = await Future.wait(futures);
//     results.addAll(batchResults);
//   }

//   return results;
// }

// // SOLUTION 6: Optimized Compression Settings
// Future<File> _compressWithSettings(
//   File file,
//   int quality,
//   int maxDimension,
// ) async {
//   final String targetPath =
//       '${file.parent.path}/opt_${DateTime.now().millisecondsSinceEpoch}.jpg';

//   final XFile? result = await FlutterImageCompress.compressAndGetFile(
//     file.absolute.path,
//     targetPath,
//     quality: quality,
//     minWidth: maxDimension,
//     minHeight: maxDimension,
//     autoCorrectionAngle: false, // Disable if not needed
//     keepExif: false, // Remove metadata to reduce size
//     format: CompressFormat.jpeg,
//     numberOfRetries: 1, // Reduce retry attempts
//   );

//   return result != null ? File(result.path) : file;
// }

// // SOLUTION 7: Image Picker with Built-in Compression
// Future<void> _pickImagesOptimized() async {
//   final List<XFile>? images = await _picker.pickMultiImage(
//     maxWidth: 1200, // Limit resolution at source
//     maxHeight: 1200,
//     imageQuality: 85, // Compress during selection
//   );

//   if (images != null && images.isNotEmpty) {
//     for (XFile image in images) {
//       if (_selectedImages.length < 4) {
//         // Skip additional compression if already optimized
//         final file = File(image.path);
//         final size = await file.length();

//         if (size > 1024 * 1024) {
//           // Only compress if > 1MB
//           final compressed = await _optimizeImageSmart(file);
//           setState(() => _selectedImages.add(compressed));
//         } else {
//           setState(() => _selectedImages.add(file));
//         }
//       }
//     }
//   }
// }

// // SOLUTION 8: Deferred Upload Strategy
// class DeferredImageUpload {
//   static final List<File> _uploadQueue = [];
//   static bool _isUploading = false;

//   // Add images to upload queue and return placeholder
//   static String queueImageForUpload(File image) {
//     _uploadQueue.add(image);
//     final placeholderId =
//         'placeholder_${DateTime.now().millisecondsSinceEpoch}';

//     // Start background upload if not already running
//     if (!_isUploading) {
//       _startBackgroundUpload();
//     }

//     return placeholderId;
//   }

//   static Future<void> _startBackgroundUpload() async {
//     _isUploading = true;

//     while (_uploadQueue.isNotEmpty) {
//       final image = _uploadQueue.removeAt(0);
//       try {
//         // Process and upload image in background
//         final processed = await _optimizeImageSmart(image);
//         await _uploadToFirebase(processed);
//       } catch (e) {
//         print('Background upload failed: $e');
//       }
//     }

//     _isUploading = false;
//   }
// }

// // SOLUTION 9: Cache Compressed Images
// class ImageCache {
//   static final Map<String, File> _cache = {};

//   static Future<File> getCachedOrCompress(File original) async {
//     final key = '${original.path}_${await original.lastModified()}';

//     if (_cache.containsKey(key)) {
//       return _cache[key]!;
//     }

//     final compressed = await _optimizeImageSmart(original);
//     _cache[key] = compressed;

//     // Limit cache size
//     if (_cache.length > 10) {
//       _cache.remove(_cache.keys.first);
//     }

//     return compressed;
//   }
// }

// // IMPLEMENTATION IN YOUR EXISTING CODE:

// // Replace your current _processImagesInBatch method:
// Future<List<File>> _processImagesInBatch(List<File> images) async {
//   // Show progress dialog
//   showDialog(
//     CustomNotificationHandler.navigatorKey.currentContext!: CustomNotificationHandler.navigatorKey.currentContext!,
//     barrierDismissible: false,
//     builder: (CustomNotificationHandler.navigatorKey.currentContext!) => AlertDialog(
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           CircularProgressIndicator(),
//           SizedBox(height: 16),
//           Text('Processing images...'),
//         ],
//       ),
//     ),
//   );

//   try {
//     // Use parallel processing with limited concurrency
//     final results = await _processImagesParallel(images);
//     Navigator.pop(CustomNotificationHandler.navigatorKey.currentContext!); // Close progress dialog
//     return results;
//   } catch (e) {
//     Navigator.pop(CustomNotificationHandler.navigatorKey.currentContext!); // Close progress dialog
//     rethrow;
//   }
// }

// // Replace your current _pickImages method:
// Future<void> _pickImages() async {
//   PermissionStatus status = await Permission.photos.request();

//   if (status.isGranted) {
//     // Use optimized picker with built-in compression
//     await _pickImagesOptimized();
//     _updateFieldStatus('images', _selectedImages.isNotEmpty);
//   } else {
//     ScaffoldMessenger.of(CustomNotificationHandler.navigatorKey.currentContext!).showSnackBar(
//       const SnackBar(content: Text('Permission denied to access photos')),
//     );
//   }
// }
