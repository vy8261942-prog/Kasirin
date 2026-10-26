# Kasirin Mobile

Flutter/Dart POS client for Android and iOS. POS data is stored in a separate app-private SQLite database on each device. There is no transaction synchronization with the desktop app or billing server.

## Toolchain

- Flutter stable 3.47.8 and Dart 3.13.7 are the current verified versions.
- Android Studio and Android SDK are required for Android builds. Configure Android SDK command-line tools, platform-tools, build-tools, and accept normal SDK licenses before building.
- iOS simulator/device builds require macOS and Xcode. This Windows workspace has not built or signed iOS.
- Android application ID: `com.kasirin.kasirin_mobile`; minimum SDK: 23. Release signing is intentionally not configured with repository secrets.

## Local Development

From this directory:

```powershell
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter build apk --debug
```

The current Windows environment has Flutter at `C:\src\flutter`, but it is not on PATH. Use `C:\src\flutter\bin\flutter.bat` and `C:\src\flutter\bin\dart.bat`, or add the SDK's `bin` directory to the user PATH. The detected Android SDK currently lacks `cmdline-tools`; install that component through Android Studio's SDK Manager or the official Android command-line tools distribution, then rerun `flutter doctor -v`.

Drift is currently implemented with explicit SQL statements in `lib/data/local_database.dart`; no build_runner generation step is configured. The database is at the application-support path as `kasirin.db`. Schema version is 1. Do not ship schema changes without ordered, non-destructive migrations and upgrade tests.

## Current App Flows

- Fresh database presents OWNER/store setup with no demo records.
- Local login, inactive-user rejection, failed-login count/lockout, and login history are repository-backed. Existing desktop Argon2 password hashes are not compatible with the mobile PBKDF2 format; importing desktop users is not supported.
- OWNER/ADMIN/SUPERVISOR see the responsive overview, cashier, product list, and additional-features status. CASHIER is routed directly to cashier and cannot open the overview/product route through app navigation.
- Product search supports name, SKU, and barcode text (including keyboard-wedge scanner input). Product creation supports SKU, name, cost/selling price, and initial/minimum stock.
- A cashier can open a shift, add products to a cart, see repository-calculated tier prices, accept cash, and save the sale locally. Sale, lines, payment, stock movement, journal and audit writes are transactional and invoice-key retries are idempotent.
- Cashier UI currently supports cash only; shift close, discounts, customer selection, receipt printing/sharing and refunds are not implemented.

See [desktop-parity-matrix.md](docs/desktop-parity-matrix.md) and [database-parity.md](docs/database-parity.md) for the implementation status and gaps.

## Platform and Security Boundaries

- Billing dependencies are not yet wired to the existing `billing_server`. Configure no production endpoint or credentials in this app until the server DTO/auth contract is audited and platform-aware licensing is implemented.
- No billing customer token, device token, signing key, payment secret, or production credential is bundled. POS transactions remain local and work without network access.
- Camera, printer, document export, backup, and hardware adapters have not been implemented or device-tested.
- Final iOS archive/IPA build and signing can only be verified on macOS with Xcode.
