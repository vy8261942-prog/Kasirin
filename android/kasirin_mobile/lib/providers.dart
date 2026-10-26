import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

import 'data/local_database.dart';
import 'domain/password_hasher.dart';
import 'domain/pos_repository.dart';
import 'services/billing_client.dart';
import 'services/billing_config.dart';
import 'views/auth/auth_state.dart';

// --- Riverpod providers ---

final databaseProvider = FutureProvider<KasirinDatabase>((ref) async {
  final directory = await getApplicationSupportDirectory();
  final db = KasirinDatabase(
    NativeDatabase.createInBackground(
      File(p.join(directory.path, 'kasirin.db')),
      setup: _configureSqlite,
    ),
  );
  await db.customSelect('SELECT 1').get();
  return db;
});

final passwordHasherProvider = Provider<PasswordHasher>((ref) => PasswordHasher());

final posRepositoryProvider = Provider<PosRepository>((ref) {
  final databaseAsync = ref.watch(databaseProvider);
  final passwordHasher = ref.read(passwordHasherProvider);
  return PosRepository(databaseAsync.requireValue, passwordHasher);
});

final billingConfigProvider = Provider<BillingConfig>((ref) {
  return BillingConfig(
    baseUrl: 'https://trimester-slaw-papaya.ngrok-free.dev',
    apiPrefix: '',
  );
});

final billingClientProvider = Provider<BillingClient>((ref) {
  return BillingClient();
});

// --- Auth ---

final authNotifierprovider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

// --- Theme ---

final themeProvider = Provider((ref) => ThemeData(
  primarySwatch: Colors.blue,
  useMaterial3: true,
  scaffoldBackgroundColor: Colors.white,
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    ),
    titleLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    ),
    bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
    bodyMedium: TextStyle(fontSize: 14, color: Colors.black87),
    labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey.shade100,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.blue, width: 2),
    ),
  ),
));

// --- GoRouter ---

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierprovider);
  return GoRouter(
    initialLocation: authState.isAuthenticated ? '/' : '/login',
    redirect: (context, state) {
      final authState = ref.read(authNotifierprovider);
      if (!authState.isAuthenticated) {
        return '/login';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginView()),
      GoRoute(path: '/license', builder: (context, state) => const LicenseView()),
      GoRoute(
        path: '/',
        builder: (context, state) => const DashboardView(),
        routes: [
          GoRoute(path: 'cashier', builder: (context, state) => const CashierView()),
          GoRoute(
            path: 'user-management',
            builder: (context, state) => const UserManagementView(),
          ),
          GoRoute(path: 'master-data', builder: (context, state) => const MasterDataView()),
          GoRoute(path: 'purchase', builder: (context, state) => const PurchaseView()),
          GoRoute(
            path: 'report-center',
            builder: (context, state) => const ReportCenterView(),
          ),
          GoRoute(path: 'store-settings', builder: (context, state) => const StoreSettingsView()),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Halaman tidak ditemukan: ${state.error}')),
    ),
  );
});

void _configureSqlite(sqlite.Database database) {
  database.execute('PRAGMA foreign_keys = ON');
  database.execute('PRAGMA journal_mode = WAL');
  database.execute('PRAGMA busy_timeout = 5000');
}