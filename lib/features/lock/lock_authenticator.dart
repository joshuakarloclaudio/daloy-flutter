import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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

  /// "Face ID", "Touch ID", "Fingerprint" or just "Passcode" — what to call it.
  Future<String> label() async {
    final ios = defaultTargetPlatform == TargetPlatform.iOS;
    try {
      final types = await _auth.getAvailableBiometrics();
      if (types.contains(BiometricType.face)) return ios ? 'Face ID' : 'Face unlock';
      if (types.contains(BiometricType.fingerprint)) return ios ? 'Touch ID' : 'Fingerprint';
    } on Object {
      // Fall through to the passcode.
    }
    return ios ? 'Passcode' : 'Screen lock';
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
