import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Authentication service for app-level security.
///
/// Provides:
/// - PIN-based lock screen (stored securely)
/// - Biometric authentication (fingerprint/face)
/// - Lock/unlock state management
class AuthService {
  AuthService._();

  static const _storage = FlutterSecureStorage();
  static final _localAuth = LocalAuthentication();

  static const String _pinKey = 'app_pin';
  static const String _pinEnabledKey = 'pin_enabled';
  static const String _biometricEnabledKey = 'biometric_enabled';

  // ─── PIN Management ────────────────────────────────────

  /// Check if PIN is set up.
  static Future<bool> isPinEnabled() async {
    final value = await _storage.read(key: _pinEnabledKey);
    return value == 'true';
  }

  /// Set a new PIN.
  static Future<void> setPin(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
    await _storage.write(key: _pinEnabledKey, value: 'true');
  }

  /// Verify the entered PIN.
  static Future<bool> verifyPin(String pin) async {
    final storedPin = await _storage.read(key: _pinKey);
    return storedPin == pin;
  }

  /// Change PIN (requires old PIN verification).
  static Future<bool> changePin(String oldPin, String newPin) async {
    final isValid = await verifyPin(oldPin);
    if (!isValid) return false;
    await setPin(newPin);
    return true;
  }

  /// Remove PIN lock.
  static Future<void> removePin() async {
    await _storage.delete(key: _pinKey);
    await _storage.write(key: _pinEnabledKey, value: 'false');
  }

  // ─── Biometric Authentication ──────────────────────────

  /// Check if biometric auth is available on the device.
  static Future<bool> isBiometricAvailable() async {
    try {
      final canAuthenticate = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canAuthenticate && isDeviceSupported;
    } catch (_) {
      return false;
    }
  }

  /// Get available biometric types.
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  /// Check if biometric is enabled by user.
  static Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _biometricEnabledKey);
    return value == 'true';
  }

  /// Enable/disable biometric authentication.
  static Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(
      key: _biometricEnabledKey,
      value: enabled ? 'true' : 'false',
    );
  }

  /// Authenticate using biometrics.
  static Future<bool> authenticateWithBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access Loan Ledger',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  // ─── Combined Auth Flow ────────────────────────────────

  /// Check if any authentication is required.
  static Future<bool> isAuthRequired() async {
    final pinEnabled = await isPinEnabled();
    final biometricEnabled = await isBiometricEnabled();
    return pinEnabled || biometricEnabled;
  }
}
