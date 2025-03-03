import 'dart:async';
import 'dart:io';

import 'package:appname_models/appname_models.dart';
import 'package:appname_server/main.dart';
import 'package:appname_server/server/api/example.dart';
import 'package:appname_server/server/util/routing.dart';
import 'package:appname_server/server/service/storage_service.dart';
import 'package:appname_server/server/util/request_authenticator.dart';
import 'package:fast_log/fast_log.dart';
import 'package:fire_api/fire_api.dart';
import 'package:fire_api_dart/fire_api_dart.dart';
import 'package:google_cloud/google_cloud.dart';
import 'package:multimedia/loader.dart';
import 'package:multimedia/magick/image_magick.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';

class AppNameServer implements Routing {
  static late final AppNameServer instance;
  late final HttpServer server;
  late final RequestAuthenticator authenticator;

  // Services
  late final StorageService svcStorage;

  // APIs
  late final ExampleAPI apiExample;

  Future<void> start() async {
    instance = this;
    await Future.wait([
      initMultimedia(
          overrideLibrary: File("/app/./bundle/libimage_magick_ffi.so")),
      GoogleCloudFirestoreDatabase.create(),
      _startServices(),
      _startAPIs()
    ]);

    FirestoreDatabase.instance.debugLogging = false;
    $registerModels();

    authenticator = RequestAuthenticator();

    // Start Server
    server = await serve(_pipeline, InternetAddress.anyIPv4, listenPort());
  }

  Future<void> _startServices() async {
    svcStorage = StorageService();
    await Future.wait([svcStorage.start(), _startMagick()]);
    verbose("Services Online");
  }

  Future<void> _startMagick() async {
    try {
      MagickWand wand = MagickWand.newMagickWand();
      await wand.destroyMagickWand();
      verbose('Magick Online');
    } catch (e, es) {
      error('MagickWand Error: $e');
      error('Stack Trace: $es');
    }
  }

  Future<void> _startAPIs() async {
    apiExample = ExampleAPI();
    verbose("APIs Initialized");
  }

  Future<Response> _onError(Object err, StackTrace stackTrace) async {
    error('Request Error: $err');
    error('Stack Trace: $stackTrace');
    return Response.internalServerError();
  }

  Future<Response?> _onRequest(Request request) =>
      authenticator.authenticateRequest(request);

  Future<Response> _onResponse(Response response) async {
    return response;
  }

  Handler get _pipeline => Pipeline()
      .addMiddleware(_corsMiddleware)
      .addMiddleware(_middleware)
      .addHandler(router.call);

  @override
  String get prefix => "/";

  Middleware get _middleware => createMiddleware(
        requestHandler: _onRequest,
        errorHandler: _onError,
        responseHandler: _onResponse,
      );

  Middleware get _corsMiddleware => corsHeaders(headers: {
        ACCESS_CONTROL_ALLOW_ORIGIN: "*",
        ACCESS_CONTROL_ALLOW_METHODS: "GET, POST, PUT, DELETE, OPTIONS",
        ACCESS_CONTROL_ALLOW_HEADERS: "*",
      });

  @override
  Router get router => Router()
    ..mount(apiExample.prefix, apiExample.router.call)
    ..get("/keepAlive", _requestGetKeepAlive);

  Future<Response> _requestGetKeepAlive(Request request) async =>
      Response.ok('{"ok": true}');

  Future<void> bindRenderContext(AppNameServerVirtualContextState state) async {
    success("AppName Server started in ${pStartup.getMilliseconds()}ms");
  }
}
