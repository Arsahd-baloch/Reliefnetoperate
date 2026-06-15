import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:reliefnet_app/core/router/app_router.dart';
import 'package:reliefnet_app/core/theme/app_theme.dart';
import 'package:reliefnet_app/core/sync/sync_service.dart';
import 'package:reliefnet_app/core/database/app_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Sync Service
  final db = AppDatabase();
  final syncService = SyncService(db);
  await syncService.init();

  const stripePk =
      String.fromEnvironment('STRIPE_PK', defaultValue: '');
  if (stripePk.isNotEmpty) {
    Stripe.publishableKey = stripePk;
    await Stripe.instance.applySettings();
  }

  runApp(
    const ProviderScope(
      child: ReliefNetApp(),
    ),
  );
}

class ReliefNetApp extends ConsumerWidget {
  const ReliefNetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'ReliefNet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
