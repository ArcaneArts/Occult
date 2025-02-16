import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'server_signature.mapper.dart';

/// This is used to validate requests to the server piggy backing off of firestore security
@MappableClass()
class AppNameSignature with AppNameSignatureMappable {
  final String signature;
  final String session;
  final int time;

  AppNameSignature({
    required this.signature,
    required this.session,
    required this.time,
  });

  static String? _sessionId;
  static String get sessionId {
    if (_sessionId == null) {
      Random r = Random();
      _sessionId =
          base64Encode(List.generate(128, (i) => r.nextInt(256)).toList());
    }

    return _sessionId!;
  }

  String get hash =>
      sha256.convert(utf8.encode("$signature:$session@$time")).toString();

  static String get randomSignature {
    Random random = Random();
    return base64Encode(
        List.generate(128, (i) => random.nextInt(256)).toList());
  }

  static AppNameSignature newSignature() => AppNameSignature(
        signature: randomSignature,
        session: sessionId,
        time: DateTime.timestamp().millisecondsSinceEpoch,
      );
}
