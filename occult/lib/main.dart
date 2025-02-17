import 'dart:async';

import 'package:caremap_server/server/caremap_server.dart';
import 'package:fast_log/fast_log.dart';
import 'package:flutter/material.dart';
import 'package:precision_stopwatch/precision_stopwatch.dart';
import 'package:toxic/extensions/future.dart';

late Future<CMServer> _server;
late Completer<void> _online;
late PrecisionStopwatch pStartup;

void main() {
  pStartup = PrecisionStopwatch.start();
  _online = Completer<void>();
  info("Starting CareMap Server");
  CMServer s = CMServer();
  _server = s.start().then((_) => s);
  runApp(CMServerApplication());
}

class CMServerApplication extends StatelessWidget {
  const CMServerApplication({super.key});

  @override
  Widget build(BuildContext context) =>
      MaterialApp(color: Colors.blue, home: CMServerVirtualContext());
}

class CMServerVirtualContext extends StatefulWidget {
  const CMServerVirtualContext({super.key});

  @override
  State<CMServerVirtualContext> createState() => CMServerVirtualContextState();
}

class CMServerVirtualContextState extends State<CMServerVirtualContext> {
  @override
  void initState() {
    super.initState();
    verbose("CareMap Render Context Online");
    _server
        .then((s) => s.bindRenderContext(this))
        .thenRun((_) => _online.complete());
  }

  @override
  Widget build(BuildContext context) => Placeholder();
}
