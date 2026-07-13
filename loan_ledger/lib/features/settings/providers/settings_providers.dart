import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../models/enums.dart';

/// Theme mode provider.
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});

/// Settings state provider.
final settingsProvider = StateProvider<Map<String, dynamic>>((ref) {
  return {
    'theme': AppThemeMode.system,
    'language': AppConstants.defaultLanguage,
    'currency': AppConstants.defaultCurrency,
    'pinEnabled': false,
    'biometricEnabled': false,
  };
});
