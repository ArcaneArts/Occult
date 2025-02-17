import 'dart:convert';

import 'package:shelf/shelf.dart';

extension XStreamString on Stream<String> {
  Response get streamedResponse => Response.ok(map((e) => utf8.encode(e)),
      context: {"shelf.io.buffer_output": false});
}
