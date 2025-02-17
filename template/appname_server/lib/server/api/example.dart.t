/*
 * Copyright (c) 2024. Crucible Labs Inc.
 *
 * Crucible is a closed source project developed by Crucible Labs Inc. 
 * Do not copy, share distribute or otherwise allow this source file 
 * to leave hardware approved by Crucible Labs Inc. unless otherwise 
 * approved by Crucible Labs Inc.
 */

import 'dart:convert';

import 'package:appname_models/appname_models.dart';
import 'package:appname_server/server/appname_server.dart';
import 'package:appname_server/server/net/routing.dart';
import 'package:appname_server/server/util/extensions.dart';
import 'package:fire_crud/fire_crud.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class ExampleAPI implements Routing {
  @override
  String get prefix => "/example";

  @override
  Router get router => Router()..get("/ping", ping);

  Future<Response> ping(Request request) async {
    return Response.ok(jsonEncode({"message": "pong"}));
  }
}
