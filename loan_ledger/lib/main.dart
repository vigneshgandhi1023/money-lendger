/// Loan Ledger — Premium Fintech App for Small Money Lenders
///
/// Entry point for the application. Initializes Hive local storage,
/// Firebase (optional), notifications, and launches the app.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/services/storage_service.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode for optimal one-hand usage
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Hive for offline-first local storage
  await Hive.initFlutter();
  await StorageService.initialize();

  // Initialize local notifications
  await NotificationService.initialize();

  // Firebase initialization (optional — app works fully offline)
  // Uncomment when google-services.json is configured:
  // await Firebase.initializeApp();

  runApp(
    const ProviderScope(
      child: LoanLedgerApp(),
    ),
  );
}
