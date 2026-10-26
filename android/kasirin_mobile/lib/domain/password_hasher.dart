import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

class PasswordHasher {
  static const _iterations = 310000;
  static const _algorithmName = 'pbkdf2_sha256';
  static final _algorithm = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: _iterations,
    bits: 256,
  );

  Future<String> hash(String password) async {
    if (password.isEmpty) {
      throw ArgumentError.value(password, 'password', 'Password wajib diisi.');
    }
    final random = Random.secure();
    final salt = List<int>.generate(16, (_) => random.nextInt(256));
    final derived = await _derive(password, salt);
    return '\$$_algorithmName\$$_iterations\$${base64UrlEncode(salt)}\$${base64UrlEncode(derived)}';
  }

  Future<bool> verify(String password, String encoded) async {
    final parts = encoded.split(r'$');
    if (parts.length != 5 || parts[1] != _algorithmName) {
      return false;
    }
    final iterations = int.tryParse(parts[2]);
    if (iterations == null || iterations < 100000 || iterations > 1000000) {
      return false;
    }
    try {
      final salt = base64Url.decode(base64Url.normalize(parts[3]));
      final expected = base64Url.decode(base64Url.normalize(parts[4]));
      final actual = await Pbkdf2(
        macAlgorithm: Hmac.sha256(),
        iterations: iterations,
        bits: expected.length * 8,
      ).deriveKey(secretKey: SecretKey(utf8.encode(password)), nonce: salt);
      final actualBytes = await actual.extractBytes();
      if (actualBytes.length != expected.length) return false;
      var difference = 0;
      for (var index = 0; index < actualBytes.length; index++) {
        difference |= actualBytes[index] ^ expected[index];
      }
      return difference == 0;
    } on FormatException {
      return false;
    }
  }

  Future<List<int>> _derive(String password, List<int> salt) async {
    final key = await _algorithm.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );
    return key.extractBytes();
  }
}
