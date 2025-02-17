import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

abstract class Routing {
  Router get router;

  String get prefix;
}

extension XRequest on Request {
  String? param(String key) => url.queryParameters[key];
}
