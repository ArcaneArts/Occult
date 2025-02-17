import 'dart:convert';

import 'package:appname/service/user_service.dart';
import 'package:appname_models/appname_models.dart';
import 'package:arcane_auth/arcane_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:serviced/serviced.dart';

const String devServer = "http://localhost:8080";
const String prodServer = "https://api.yourserver.com";
const bool useDevServer = true && kDebugMode;

class CMSService extends StatelessService {
  Future<String> summarizeEntry(String record, String entry) async =>
      get("example/ping").then((i) => i.body);

  Future<http.Response> get(String path,
          {Map<String, String> query = const {}}) async =>
      http.get(
          Uri.parse("${useDevServer ? devServer : prodServer}/$path").replace(
            queryParameters: query,
          ),
          headers: {...(await authenticationHeaders)});

  Future<http.Response> post(String path,
          {Map<String, String> query = const {},
          Map<String, dynamic> body = const {}}) async =>
      http.post(
        Uri.parse("${useDevServer ? devServer : prodServer}/$path").replace(
          queryParameters: query,
        ),
        headers: {...(await authenticationHeaders)},
        body: jsonEncode(body),
      );

  Future<Map<String, String>> get authenticationHeaders async =>
      {"cm-uid": $uid!, "cm-sih": (await signature).hash};

  Future<AppNameSignature> get signature => $settings.clientAppNameSignature;
}
