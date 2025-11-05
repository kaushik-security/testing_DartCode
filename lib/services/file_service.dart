import 'dart:io';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

class FileService {
  final String uploadDir;
  
  FileService(this.uploadDir) {
    // Create upload directory if it doesn't exist
    Directory(uploadDir).createSync(recursive: true);
  }
  
  // UNSAFE: No file type validation, no size limits, vulnerable to path traversal
  Future<Map<String, dynamic>> saveUploadedFile(
    String fileName, 
    List<int> fileBytes, 
    {String? customPath}
  ) async {
    // UNSAFE: No validation of file extension or content type
    final safeFileName = path.basename(fileName);
    
    // UNSAFE: Potential path traversal if customPath contains '../'
    final savePath = customPath != null 
        ? path.join(uploadDir, customPath, safeFileName)
        : path.join(uploadDir, safeFileName);
    
    // UNSAFE: No check for file size
    await File(savePath).writeAsBytes(fileBytes);
    
    // UNSAFE: Guessing MIME type from extension, not content
    final mimeType = lookupMimeType(safeFileName) ?? 'application/octet-stream';
    
    return {
      'originalName': fileName,
      'savedPath': savePath,
      'size': fileBytes.length,
      'mimeType': mimeType,
      'url': '/uploads/${customPath != null ? '$customPath/' : ''}$safeFileName'
    };
  }
  
  // UNSAFE: Arbitrary file read
  Future<String> readFile(String filePath) async {
    // UNSAFE: No path traversal protection
    final file = File(path.join(uploadDir, filePath));
    return await file.readAsString();
  }
  
  // UNSAFE: Directory listing
  List<Map<String, dynamic>> listFiles({String? subDir}) {
    final dir = subDir != null 
        ? Directory(path.join(uploadDir, subDir))
        : Directory(uploadDir);
        
    return dir.listSync().map((entity) {
      if (entity is File) {
        return {
          'name': path.basename(entity.path),
          'path': entity.path,
          'size': entity.lengthSync(),
          'modified': entity.lastModifiedSync(),
          'type': 'file',
        };
      } else if (entity is Directory) {
        return {
          'name': path.basename(entity.path),
          'path': entity.path,
          'type': 'directory',
        };
      }
      return null;
    }).whereType<Map<String, dynamic>>().toList();
  }
  
  // UNSAFE: No input validation or sanitization
  Future<void> processUserInput(String userInput) async {
    // UNSAFE: Directly using user input in a shell command
    await Process.run('echo', [userInput]);
  }
}
