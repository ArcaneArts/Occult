import 'package:shelf/shelf.dart';

extension XRequest on Request {
  String get uid => headers["cm-uid"]!;
  String get sih => headers["cm-sih"]!;
}
