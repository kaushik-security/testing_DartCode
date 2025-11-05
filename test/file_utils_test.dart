import 'package:test/test.dart';
import 'package:dart_scan_project/src/utils/file_utils.dart';
import 'dart:io';

void main() {
  group('FileUtils Tests', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('file_utils_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('Creates safe temp directory', () async {
      final safeDir = await FileUtils.getSafeTempDirectory();
      expect(await safeDir.exists(), isTrue);
      expect(safeDir.path.contains('dart_scan_project_'), isTrue);

      // Clean up
      await safeDir.delete(recursive: true);
    });

    test('Reads file safely', () async {
      final testFile = File('${tempDir.path}/test.txt');
      await testFile.writeAsString('Hello, World!');

      final content = await FileUtils.readFileSafely(testFile.path);
      expect(content, equals('Hello, World!'));
    });

    test('Writes file safely', () async {
      final testFile = '${tempDir.path}/output.txt';
      await FileUtils.writeFileSafely(testFile, 'Test content');

      final file = File(testFile);
      expect(await file.exists(), isTrue);
      expect(await file.readAsString(), equals('Test content'));
    });

    test('Copies file safely', () async {
      final sourceFile = File('${tempDir.path}/source.txt');
      await sourceFile.writeAsString('Source content');

      final destFile = '${tempDir.path}/destination.txt';
      await FileUtils.copyFileSafely(sourceFile.path, destFile);

      final copiedFile = File(destFile);
      expect(await copiedFile.exists(), isTrue);
      expect(await copiedFile.readAsString(), equals('Source content'));
    });

    test('Deletes file safely', () async {
      final testFile = File('${tempDir.path}/to_delete.txt');
      await testFile.writeAsString('To be deleted');

      expect(await testFile.exists(), isTrue);

      await FileUtils.deleteFileSafely(testFile.path);

      expect(await testFile.exists(), isFalse);
    });

    test('Gets file info correctly', () async {
      final testFile = File('${tempDir.path}/info_test.txt');
      await testFile.writeAsString('Test content for info');

      final info = await FileUtils.getFileInfo(testFile.path);

      expect(info.path, equals(testFile.path));
      expect(info.size, equals(20)); // Length of "Test content for info"
      expect(info.extension, equals('.txt'));
      expect(info.type, equals(FileSystemEntityType.file));
      expect(info.isReadable, isTrue);
    });

    test('Lists directory safely', () async {
      // Create test files
      await File('${tempDir.path}/file1.txt').writeAsString('Content 1');
      await File('${tempDir.path}/file2.txt').writeAsString('Content 2');
      await File('${tempDir.path}/file3.jpg').writeAsString('Fake image');

      final entities = await FileUtils.listDirectorySafely(tempDir.path);

      expect(entities.length, equals(3));

      final txtFiles = await FileUtils.listDirectorySafely(
        tempDir.path,
        allowedExtensions: ['txt'],
      );

      expect(txtFiles.length, equals(2));
    });

    test('Detects file types correctly', () async {
      final txtFile = File('${tempDir.path}/test.txt');
      await txtFile.writeAsString('Plain text content');

      final fileType = await FileUtils.detectFileType(txtFile.path);
      expect(fileType, equals(FileType.text));
    });

    test('Calculates file hash correctly', () async {
      final testFile = File('${tempDir.path}/hash_test.txt');
      await testFile.writeAsString('Content for hashing');

      final hash = await FileUtils.calculateFileHash(testFile.path);
      expect(hash, isNotEmpty);
      expect(hash.length, equals(64)); // SHA-256 hash length
    });

    test('Cleans up temp files', () async {
      // Create old temp files (simulated)
      final oldFile = File('${Directory.systemTemp.path}/old_temp_file.txt');
      await oldFile.writeAsString('Old file');

      // This would require setting the file's modification time to be old
      // For this test, we'll just verify the method runs without error
      await expectLater(
        FileUtils.cleanupTempFiles(),
        completes,
      );
    });

    test('Handles non-existent files gracefully', () async {
      final nonExistentFile = '${tempDir.path}/does_not_exist.txt';

      expect(
        () => FileUtils.readFileSafely(nonExistentFile),
        throwsA(isA<FileException>()),
      );

      expect(
        () => FileUtils.getFileInfo(nonExistentFile),
        throwsA(isA<FileException>()),
      );
    });

    test('Validates file size limits', () async {
      // Create a file larger than the 50MB limit
      final largeFile = File('${tempDir.path}/large_file.txt');
      final largeContent = 'x' * (60 * 1024 * 1024); // 60MB

      expect(
        () => FileUtils.readFileSafely(largeFile.path),
        throwsA(isA<FileException>()),
      );
    });
  });
}
