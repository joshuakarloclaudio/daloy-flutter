import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/utils/platform.dart';

part 'lock_authenticator.g.dart';

/// The device's own "is it you?" check — Face ID, a fingerprint, or the
/// passcode when neither is set up. A seam so tests don't need a phone.
class LockAuthenticator {
  LockAuthenticator([LocalAuthentication? auth]) : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  /// False when the phone has no biometrics and no passcode to fall back on.
  Future<bool> isSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } on Object {
      return false;
    }
  }

  /// "Face ID", "Touch ID", "Fingerprint" or just "Passcode" (the Mac's
  /// login "Password", "Windows Hello") — what to call it.
  Future<String> label() async {
    // Windows Hello is the face, the fingerprint and the PIN alike.
    if (isWindows) return 'Windows Hello';
    final apple = defaultTargetPlatform.isApple;
    try {
      final types = await _auth.getAvailableBiometrics();
      if (types.contains(BiometricType.face)) return apple ? 'Face ID' : 'Face unlock';
      if (types.contains(BiometricType.fingerprint)) return apple ? 'Touch ID' : 'Fingerprint';
    } on Object {
      // Fall through to the passcode.
    }
    if (isMacOS) return 'Password';
    return apple ? 'Passcode' : 'Screen lock';
  }

  /// True once the person has proved who they are. A cancelled or failed
  /// attempt is just false.
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(localizedReason: reason, persistAcrossBackgrounding: true);
    } on Object {
      return false;
    }
  }
}

@Riverpod(keepAlive: true)
LockAuthenticator lockAuthenticator(Ref ref) => LockAuthenticator();
