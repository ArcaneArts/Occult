import 'package:appname_models/appname_models.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:fire_crud/fire_crud.dart';

part 'user_settings.mapper.dart';

@MappableClass()
class AppNameUserSettings with AppNameUserSettingsMappable, ModelCrud {
  final String? theme;
  /// This is needed to ensure that the user can request the server
  final List<AppNameSignature> serverSignatures;

  AppNameUserSettings({
    this.theme,
    this.serverSignatures = const [],
  });

  bool get hasValidAppNameSignature => serverSignatures.any((i) =>
      i.session == AppNameSignature.sessionId &&
      DateTime.timestamp().millisecondsSinceEpoch - i.time <
          Duration(minutes: 5).inMilliseconds);

  AppNameSignature get anyValidAppNameSignature =>
      serverSignatures.firstWhere((i) =>
          i.session == AppNameSignature.sessionId &&
          DateTime.timestamp().millisecondsSinceEpoch - i.time <
              Duration(minutes: 5).inMilliseconds);

  Future<AppNameSignature> get clientAppNameSignature async {
    if (!hasValidAppNameSignature) {
      AppNameSignature sig = AppNameSignature.newSignature();
      await setSelfAtomic<AppNameUserSettings>(
          (u) => u!.copyWith(serverSignatures: [
                ...serverSignatures.where((i) =>
                    DateTime.timestamp().millisecondsSinceEpoch - i.time >
                    Duration(minutes: 10).inMilliseconds),
                sig
              ]));
      return sig;
    }

    return anyValidAppNameSignature;
  }

  @override
  List<FireModel<ModelCrud>> get childModels => [];
}
