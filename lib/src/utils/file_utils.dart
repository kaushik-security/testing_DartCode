import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;
import 'package:logger/logger.dart';
import 'security_utils.dart';

/// File utility functions for handling file operations safely
class FileUtils {
  static final Logger _logger = Logger();

  /// Get safe temporary directory
  static Future<Directory> getSafeTempDirectory() async {
    try {
      final tempDir = await Directory.systemTemp.createTemp('dart_scan_project_');
      _logger.d('Created safe temp directory: ${tempDir.path}');
      return tempDir;
    } catch (e) {
      _logger.e('Failed to create safe temp directory', e);
      throw FileException('Failed to create temp directory: ${e.toString()}');
    }
  }

  /// Safely read file contents
  static Future<String> readFileSafely(String filePath, {Encoding encoding = utf8}) async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        throw FileException('File does not exist: $filePath');
      }

      // Check file size (prevent reading huge files)
      final fileSize = await file.length();
      if (fileSize > 50 * 1024 * 1024) { // 50MB limit
        throw FileException('File too large: ${fileSize} bytes');
      }

      final contents = await file.readAsString(encoding: encoding);
      _logger.d('File read successfully: $filePath (${contents.length} characters)');

      return contents;
    } catch (e) {
      _logger.e('Failed to read file: $filePath', e);
      throw FileException('Failed to read file: ${e.toString()}');
    }
  }

  /// Safely write file contents
  static Future<void> writeFileSafely(
    String filePath,
    String contents, {
    Encoding encoding = utf8,
    bool createDirectories = true,
  }) async {
    try {
      // Validate file path
      final safePath = SecurityUtils.sanitizeFilename(path.basename(filePath));
      final directory = path.dirname(filePath);

      if (createDirectories) {
        await Directory(directory).create(recursive: true);
      }

      final file = File(path.join(directory, safePath));

      // Check if parent directory exists and is writable
      final parentDir = file.parent;
      if (!await parentDir.exists()) {
        throw FileException('Parent directory does not exist: ${parentDir.path}');
      }

      await file.writeAsString(contents, encoding: encoding);
      _logger.d('File written successfully: ${file.path}');

    } catch (e) {
      _logger.e('Failed to write file: $filePath', e);
      throw FileException('Failed to write file: ${e.toString()}');
    }
  }

  /// Safely copy file
  static Future<void> copyFileSafely(String sourcePath, String destinationPath) async {
    try {
      final sourceFile = File(sourcePath);
      final destinationFile = File(destinationPath);

      if (!await sourceFile.exists()) {
        throw FileException('Source file does not exist: $sourcePath');
      }

      // Create destination directory if needed
      await destinationFile.parent.create(recursive: true);

      await sourceFile.copy(destinationPath);
      _logger.d('File copied successfully: $sourcePath -> $destinationPath');

    } catch (e) {
      _logger.e('Failed to copy file: $sourcePath -> $destinationPath', e);
      throw FileException('Failed to copy file: ${e.toString()}');
    }
  }

  /// Safely delete file
  static Future<void> deleteFileSafely(String filePath) async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        _logger.d('File does not exist, nothing to delete: $filePath');
        return;
      }

      await file.delete();
      _logger.d('File deleted successfully: $filePath');

    } catch (e) {
      _logger.e('Failed to delete file: $filePath', e);
      throw FileException('Failed to delete file: ${e.toString()}');
    }
  }

  /// Get file information safely
  static Future<FileInfo> getFileInfo(String filePath) async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        throw FileException('File does not exist: $filePath');
      }

      final stat = await file.stat();
      final size = stat.size;
      final modified = stat.modified;
      final type = stat.type;

      // Get file extension
      final extension = path.extension(filePath).toLowerCase();

      // Check if file is readable
      final isReadable = await _checkFileReadable(file);

      return FileInfo(
        path: filePath,
        size: size,
        modified: modified,
        type: type,
        extension: extension,
        isReadable: isReadable,
      );

    } catch (e) {
      _logger.e('Failed to get file info: $filePath', e);
      throw FileException('Failed to get file info: ${e.toString()}');
    }
  }

  /// Check if file is readable
  static Future<bool> _checkFileReadable(File file) async {
    try {
      await file.readAsString();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// List directory contents safely
  static Future<List<FileSystemEntity>> listDirectorySafely(
    String directoryPath, {
    bool recursive = false,
    List<String>? allowedExtensions,
  }) async {
    try {
      final directory = Directory(directoryPath);

      if (!await directory.exists()) {
        throw FileException('Directory does not exist: $directoryPath');
      }

      final entities = <FileSystemEntity>[];

      await for (final entity in directory.list(recursive: recursive)) {
        // Filter by allowed extensions if specified
        if (allowedExtensions != null && entity is File) {
          final extension = path.extension(entity.path).toLowerCase().substring(1);
          if (!allowedExtensions.contains(extension)) {
            continue;
          }
        }

        entities.add(entity);
      }

      _logger.d('Directory listed: $directoryPath (${entities.length} items)');
      return entities;

    } catch (e) {
      _logger.e('Failed to list directory: $directoryPath', e);
      throw FileException('Failed to list directory: ${e.toString()}');
    }
  }

  /// Validate file type based on content
  static Future<FileType> detectFileType(String filePath) async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        throw FileException('File does not exist: $filePath');
      }

      // Read first few bytes to detect file type
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) return FileType.empty;

      // Check for common file signatures
      if (bytes.length >= 8) {
        final header = bytes.sublist(0, 8);

        // PDF files
        if (header[0] == 0x25 && header[1] == 0x50 && header[2] == 0x44 && header[3] == 0x46) {
          return FileType.pdf;
        }

        // PNG files
        if (header[0] == 0x89 && header[1] == 0x50 && header[2] == 0x4E && header[3] == 0x47) {
          return FileType.png;
        }

        // JPEG files
        if (header[0] == 0xFF && header[1] == 0xD8) {
          return FileType.jpeg;
        }

        // GIF files
        if (header[0] == 0x47 && header[1] == 0x49 && header[2] == 0x46) {
          return FileType.gif;
        }

        // ZIP files
        if (header[0] == 0x50 && header[1] == 0x4B) {
          return FileType.zip;
        }
      }

      // Check file extension as fallback
      final extension = path.extension(filePath).toLowerCase();

      switch (extension) {
        case '.txt':
          return FileType.text;
        case '.json':
          return FileType.json;
        case '.xml':
          return FileType.xml;
        case '.csv':
          return FileType.csv;
        case '.md':
          return FileType.markdown;
        case '.dart':
          return FileType.dart;
        case '.py':
          return FileType.python;
        case '.js':
          return FileType.javascript;
        case '.html':
          return FileType.html;
        case '.css':
          return FileType.css;
        default:
          return FileType.unknown;
      }

    } catch (e) {
      _logger.e('Failed to detect file type: $filePath', e);
      return FileType.unknown;
    }
  }

  /// Calculate file hash
  static Future<String> calculateFileHash(String filePath, {String algorithm = 'sha256'}) async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        throw FileException('File does not exist: $filePath');
      }

      final bytes = await file.readAsBytes();

      switch (algorithm.toLowerCase()) {
        case 'md5':
          final digest = md5.convert(bytes);
          return digest.toString();
        case 'sha1':
          final digest = sha1.convert(bytes);
          return digest.toString();
        case 'sha256':
        default:
          final digest = sha256.convert(bytes);
          return digest.toString();
      }

    } catch (e) {
      _logger.e('Failed to calculate file hash: $filePath', e);
      throw FileException('Failed to calculate file hash: ${e.toString()}');
    }
  }

  /// Compress file (simplified implementation)
  static Future<void> compressFile(String sourcePath, String destinationPath) async {
    try {
      // This is a simplified implementation
      // In a real scenario, you'd use an archive library
      _logger.d('File compression would be implemented here: $sourcePath -> $destinationPath');
    } catch (e) {
      _logger.e('Failed to compress file: $sourcePath', e);
      throw FileException('Failed to compress file: ${e.toString()}');
    }
  }

  /// Clean up temporary files
  static Future<void> cleanupTempFiles({Duration olderThan = const Duration(hours: 24)}) async {
    try {
      final tempDir = Directory.systemTemp;
      final now = DateTime.now();
      final cutoff = now.subtract(olderThan);

      await for (final entity in tempDir.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoff)) {
            await entity.delete();
            _logger.d('Deleted old temp file: ${entity.path}');
          }
        }
      }

      _logger.i('Temp files cleanup completed');
    } catch (e) {
      _logger.e('Failed to cleanup temp files', e);
      throw FileException('Failed to cleanup temp files: ${e.toString()}');
    }
  }
}

/// File information class
class FileInfo {
  final String path;
  final int size;
  final DateTime modified;
  final FileSystemEntityType type;
  final String extension;
  final bool isReadable;

  FileInfo({
    required this.path,
    required this.size,
    required this.modified,
    required this.type,
    required this.extension,
    required this.isReadable,
  });

  @override
  String toString() {
    return 'FileInfo(path: $path, size: $size, modified: $modified, type: $type, extension: $extension)';
  }
}

/// File type enumeration
enum FileType {
  text,
  json,
  xml,
  csv,
  markdown,
  dart,
  python,
  javascript,
  html,
  css,
  pdf,
  png,
  jpeg,
  gif,
  zip,
  unknown,
  empty,
}

/// Custom exception for file operations
class FileException implements Exception {
  final String message;

  FileException(this.message);

  @override
  String toString() => 'FileException: $message';
}
