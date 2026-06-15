import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reliefnet_app/core/database/database_provider.dart';
import 'package:reliefnet_app/core/sync/sync_service.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  final db = ref.read(databaseProvider);
  return SyncService(db);
});
