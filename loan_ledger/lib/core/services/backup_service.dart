import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'storage_service.dart';

/// Backup and restore service for Loan Ledger data.
///
/// Exports all data to a JSON file and imports from backups.
/// Files are stored in the app's documents directory.
class BackupService {
  BackupService._();

  static const String _backupFileName = 'loan_ledger_backup.json';

  /// Create a backup of all data.
  ///
  /// Returns the path to the backup file.
  static Future<String> createBackup() async {
    final data = StorageService.exportAllData();
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/loan_ledger_backup_$timestamp.json');

    await file.writeAsString(jsonString);
    return file.path;
  }

  /// Share the backup file via system share sheet.
  static Future<void> shareBackup() async {
    final path = await createBackup();
    await Share.shareXFiles(
      [XFile(path)],
      subject: 'Loan Ledger Backup',
      text: 'Loan Ledger data backup',
    );
  }

  /// Restore data from a backup file.
  static Future<void> restoreFromFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Backup file not found');
    }

    final jsonString = await file.readAsString();
    final data = json.decode(jsonString) as Map<String, dynamic>;

    // Validate backup format
    if (!data.containsKey('customers') ||
        !data.containsKey('loans') ||
        !data.containsKey('payments')) {
      throw Exception('Invalid backup file format');
    }

    await StorageService.importAllData(data);
  }

  /// Restore from a JSON string (e.g., from file picker).
  static Future<void> restoreFromJson(String jsonString) async {
    final data = json.decode(jsonString) as Map<String, dynamic>;

    if (!data.containsKey('customers') ||
        !data.containsKey('loans') ||
        !data.containsKey('payments')) {
      throw Exception('Invalid backup data');
    }

    await StorageService.importAllData(data);
  }

  /// Get list of existing backups.
  static Future<List<FileSystemEntity>> getBackups() async {
    final directory = await getApplicationDocumentsDirectory();
    final dir = Directory(directory.path);
    return dir
        .listSync()
        .where((entity) =>
            entity is File && entity.path.contains('loan_ledger_backup'))
        .toList()
      ..sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
  }

  /// Delete a backup file.
  static Future<void> deleteBackup(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
