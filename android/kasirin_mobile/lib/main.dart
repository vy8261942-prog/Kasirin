import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

import 'providers.dart';

import 'views/auth/login_view.dart';
import 'views/auth/license_view.dart';
import 'views/owner/dashboard_view.dart';
import 'views/cashier/cashier_view.dart';
import 'views/owner/user_management_view.dart';
import 'views/owner/master_data_view.dart';
import 'views/owner/purchase_view.dart';
import 'views/reports/report_center_view.dart';
import 'views/owner/store_settings_view.dart';

// --- Auth state used in KasirinApp ---

final authStateProvider = StateProvider<AuthState>((ref) {
  final notifier = ref.watch(authNotifierprovider.notifier);
  return notifier.state;
});

class KasirinApp extends ConsumerWidget {
  const KasirinApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final authState = ref.watch(authStateProvider);
    return MaterialApp.router(
      title: 'Kasirin POS',
      theme: ref.watch(themeProvider),
      routerConfig: router,
      // Initial routing based on auth state
      home: authState.isAuthenticated ? const DashboardView() : const LoginView(),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: KasirinApp()));
}