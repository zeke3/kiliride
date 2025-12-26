import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// A helper class for caching and managing downloaded documents
class DocumentCacheManager {
  // Singleton pattern
  static final DocumentCacheManager _instance =
      DocumentCacheManager._internal();
  factory DocumentCacheManager() => _instance;
  DocumentCacheManager._internal();

  /// The base directory for cached documents
  Future<Directory> get _cacheDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/document_cache');

    // Create the directory if it doesn't exist
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    return cacheDir;
  }

  /// Generate a file path for a document
  /// The documentId should be unique for each document (like invoiceId)
  Future<String> getFilePath(String documentId, String fileExtension) async {
    final dir = await _cacheDir;
    return '${dir.path}/${documentId.replaceAll(RegExp(r'[^\w\s\-]'), '_')}.$fileExtension';
  }

  /// Check if a document is already cached
  Future<bool> isDocumentCached(String documentId, String fileExtension) async {
    final filePath = await getFilePath(documentId, fileExtension);
    final file = File(filePath);
    return await file.exists();
  }

  /// Save document data to cache
  Future<File> saveDocument(
    String documentId,
    String fileExtension,
    List<int> data,
  ) async {
    final filePath = await getFilePath(documentId, fileExtension);
    final file = File(filePath);
    return await file.writeAsBytes(data);
  }

  /// Get a cached document
  Future<File?> getDocument(String documentId, String fileExtension) async {
    final filePath = await getFilePath(documentId, fileExtension);
    final file = File(filePath);

    if (await file.exists()) {
      return file;
    }

    return null;
  }

  /// Clear all cached documents
  Future<void> clearCache() async {
    final dir = await _cacheDir;
    if (await dir.exists()) {
      await dir.delete(recursive: true);
      await dir.create();
    }
  }

  /// Delete a specific cached document
  Future<bool> deleteDocument(String documentId, String fileExtension) async {
    try {
      final filePath = await getFilePath(documentId, fileExtension);
      final file = File(filePath);

      if (await file.exists()) {
        await file.delete();
        return true;
      }

      return false;
    } catch (e) {
      print('Error deleting document: $e');
      return false;
    }
  }

  /// Get cache size in MB
  Future<double> getCacheSize() async {
    final dir = await _cacheDir;
    if (!await dir.exists()) {
      return 0.0;
    }

    int totalSize = 0;
    await for (final file in dir.list(recursive: true, followLinks: false)) {
      if (file is File) {
        totalSize += await file.length();
      }
    }

    // Convert bytes to MB
    return totalSize / (1024 * 1024);
  }

  /// Get list of all cached documents
  Future<List<CachedDocument>> getAllCachedDocuments() async {
    final dir = await _cacheDir;
    if (!await dir.exists()) {
      return [];
    }

    List<CachedDocument> documents = [];
    await for (final entity in dir.list(recursive: false, followLinks: false)) {
      if (entity is File) {
        final fileName = entity.path.split('/').last;
        final fileSize = await entity.length();
        final lastModified = await entity.lastModified();

        // Extract document ID and extension from filename
        final parts = fileName.split('.');
        if (parts.length >= 2) {
          final extension = parts.last;
          final documentId = parts.take(parts.length - 1).join('.');

          documents.add(
            CachedDocument(
              id: documentId,
              extension: extension,
              filePath: entity.path,
              size: fileSize,
              lastModified: lastModified,
            ),
          );
        }
      }
    }

    return documents;
  }
}

/// Model class for cached document information
class CachedDocument {
  final String id;
  final String extension;
  final String filePath;
  final int size;
  final DateTime lastModified;

  CachedDocument({
    required this.id,
    required this.extension,
    required this.filePath,
    required this.size,
    required this.lastModified,
  });

  /// Get formatted size string (KB, MB)
  String get formattedSize {
    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
