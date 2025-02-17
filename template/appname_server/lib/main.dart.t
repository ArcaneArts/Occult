import 'dart:async';

import 'package:appname_server/server/appname_server.dart';
import 'package:fast_log/fast_log.dart';
import 'package:flutter/material.dart';
import 'package:precision_stopwatch/precision_stopwatch.dart';
import 'package:toxic/extensions/future.dart';

late Future<AppNameServer> _server;
late Completer<void> _online;
late PrecisionStopwatch pStartup;

void main() {
  pStartup = PrecisionStopwatch.start();
  _online = Completer<void>();
  info("Starting AppName Server");
  AppNameServer s = AppNameServer();
  _server = s.start().then((_) => s);
  runApp(AppNameServerApplication());
}

class AppNameServerApplication extends StatelessWidget {
  const AppNameServerApplication({super.key});

  @override
  Widget build(BuildContext context) =>
      MaterialApp(color: Colors.blue, home: AppNameServerVirtualContext());
}

class AppNameServerVirtualContext extends StatefulWidget {
  const AppNameServerVirtualContext({super.key});

  @override
  State<AppNameServerVirtualContext> createState() => AppNameServerVirtualContextState();
}

class AppNameServerVirtualContextState extends State<AppNameServerVirtualContext> {
  @override
  void initState() {
    super.initState();
    verbose("AppName Render Context Online");
    _server
        .then((s) => s.bindRenderContext(this))
        .thenRun((_) => _online.complete());
  }

  @override
  Widget build(BuildContext context) => Placeholder();
}
