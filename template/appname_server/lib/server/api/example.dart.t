import 'dart:convert';

import 'package:appname_server/server/util/routing.dart';
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
