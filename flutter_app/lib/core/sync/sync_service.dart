import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:reliefnet_app/core/database/app_database.dart';
import 'package:drift/drift.dart';

class SyncService {
  final AppDatabase _db;

  SyncService(this._db);

  Future<void> init() async {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty && results.first != ConnectivityResult.none) {
        _syncOutbox();
      }
    });
  }

  Future<void> _syncOutbox() async {
    // 1. Fetch PENDING items
    final pendingEntries = await (_db.select(_db.outboxEntries)
          ..where((t) => t.status.equals('PENDING')))
        .get();

    for (final entry in pendingEntries) {
      try {
        // 2. Perform API call based on action type
        // Placeholder for API integration logic
        debugPrint('Syncing action: ${entry.action}, payload: ${entry.payload}');

        // 3. Mark as PROCESSED if successful
        await (_db.update(_db.outboxEntries)..where((t) => t.id.equals(entry.id)))
            .write(const OutboxEntriesCompanion(status: Value('PROCESSED')));
      } catch (e) {
        debugPrint('Failed to sync entry ${entry.id}: $e');
        await (_db.update(_db.outboxEntries)..where((t) => t.id.equals(entry.id)))
            .write(const OutboxEntriesCompanion(status: Value('FAILED')));
      }
    }
  }
}
