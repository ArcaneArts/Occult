/*
 * Copyright (c) 2024. Crucible Labs Inc.
 *
 * Crucible is a closed source project developed by Crucible Labs Inc. 
 * Do not copy, share distribute or otherwise allow this source file 
 * to leave hardware approved by Crucible Labs Inc. unless otherwise 
 * approved by Crucible Labs Inc.
 */

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

abstract class Routing {
  Router get router;

  String get prefix;
}

extension XRequest on Request {
  String? param(String key) => url.queryParameters[key];
}
