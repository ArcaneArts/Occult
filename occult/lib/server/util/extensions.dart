/*
 * Copyright (c) 2024. Crucible Labs Inc.
 *
 * Crucible is a closed source project developed by Crucible Labs Inc. 
 * Do not copy, share distribute or otherwise allow this source file 
 * to leave hardware approved by Crucible Labs Inc. unless otherwise 
 * approved by Crucible Labs Inc.
 */

import 'package:shelf/shelf.dart';

extension XRequest on Request {
  String get uid => headers["cm-uid"]!;
  String get sih => headers["cm-sih"]!;
}
