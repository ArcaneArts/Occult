import 'dart:io';

import 'package:appname_models/appname_models.dart';
import 'package:fast_log/fast_log.dart';
import 'package:fire_crud/fire_crud.dart';
import 'package:memcached/memcached.dart';
import 'package:precision_stopwatch/precision_stopwatch.dart';
import 'package:shelf/shelf.dart';
import 'package:toxic/toxic.dart';

Map<String, DateTime> validAuthentications = {};
Map<String, DateTime> invalidAuthentications = {};
const int timingAttackDelay = 500;

enum AuthResponse { invalid, validated, alreadyValidated }

class RequestAuthenticator {
  int $lastCleanup = 0;

  Future<Response?> authenticateRequest(Request request) async {
    PrecisionStopwatch p = PrecisionStopwatch.start();
    int d = timingAttackDelay - p.getMilliseconds().ceil();

    Future<Response?> timing(Response? r) async {
      if (d > 0) {
        await Future.delayed(Duration(milliseconds: d));
      } else {
        warn(
            'Unauthenticated request took longer than timing attack delay of ${timingAttackDelay}ms (${p.getMilliseconds()}ms). If this happens regularly, consider increasing the delay to protect auth from timing attacks.');
      }

      return r;
    }

    return switch (await _isAuthenticatedRequest(request)) {
      AuthResponse.invalid => timing(Response.forbidden('Invalid Request')),
      AuthResponse.validated => timing(null),
      AuthResponse.alreadyValidated => null,
    };
  }

  Future<AuthResponse> _isAuthenticatedRequest(Request request) async {
    dynamic uid = request.headers["cm-uid"];
    dynamic sih = request.headers["cm-sih"];

    if (uid is! String) {
      return AuthResponse.invalid;
    }

    if (sih is! String) {
      return AuthResponse.invalid;
    }

    final String ip =
        (request.context['shelf.io.connection_info'] as HttpConnectionInfo?)
                ?.remoteAddress
                .address ??
            "?";
    String key = "$uid:$sih@$ip";
    scheduleCleanup();

    if (invalidAuthentications.containsKey(key) &&
        DateTime.timestamp()
                .difference(invalidAuthentications[key]!)
                .inMinutes <
            4) {
      return AuthResponse.invalid;
    }

    if (validAuthentications.containsKey(key) &&
        DateTime.timestamp().difference(validAuthentications[key]!).inMinutes <
            4) {
      return AuthResponse.alreadyValidated;
    }

    AppNameUser? u = await $crud.get<AppNameUser>(uid);

    if (u == null) {
      invalidAuthentications[key] = DateTime.timestamp();
      return AuthResponse.invalid;
    }

    AppNameUserSettings? settings = await u.getUnique<AppNameUserSettings>();

    if (settings == null) {
      invalidAuthentications[key] = DateTime.timestamp();
      return AuthResponse.invalid;
    }

    if (settings.serverSignatures.any((i) =>
        i.hash == sih &&
        DateTime.timestamp().millisecondsSinceEpoch - i.time <
            Duration(minutes: 10).inMilliseconds)) {
      validAuthentications[key] = DateTime.timestamp();
      return AuthResponse.validated;
    }

    invalidAuthentications[key] = DateTime.timestamp();
    return AuthResponse.invalid;
  }

  void scheduleCleanup() {
    if (DateTime.timestamp().millisecondsSinceEpoch - $lastCleanup > 60000 ||
        (validAuthentications.length + invalidAuthentications.length) > 10000) {
      validAuthentications.removeWhere(
          (key, value) => DateTime.timestamp().difference(value).inMinutes > 4);
      invalidAuthentications.removeWhere(
          (key, value) => DateTime.timestamp().difference(value).inMinutes > 4);
    }
  }
}

extension XRequest on Request {
  String get uid => headers["cm-uid"] as String;

  Future<AppNameUserCapabilities> get capabilities => getCached(
      id: "capabilities.$uid",
      getter: () =>
      $crud.model<AppNameUser>(uid).getUnique<AppNameUserCapabilities>().bang,
      duration: Duration(minutes: 5));
}
