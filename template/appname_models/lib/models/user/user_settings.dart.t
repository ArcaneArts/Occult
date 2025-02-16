import 'package:appname_models/appname_models.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:fire_crud/fire_crud.dart';

part 'user_settings.mapper.dart';

@MappableClass()
class AppNameUserSettings with AppNameUserSettingsMappable, ModelCrud {
  final String? theme;
  final List<AppNameSignature> serverSignatures;
  final String? aiModel;

  AppNameUserSettings({
    this.theme,
    this.serverSignatures = const [],
    this.aiModel,
  });

  bool get hasValidForgeSignature => serverSignatures.any((i) =>
      i.session == AppNameSignature.sessionId &&
      DateTime.timestamp().millisecondsSinceEpoch - i.time <
          Duration(minutes: 5).inMilliseconds);

  AppNameSignature get anyValidForgeSignature =>
      serverSignatures.firstWhere((i) =>
          i.session == AppNameSignature.sessionId &&
          DateTime.timestamp().millisecondsSinceEpoch - i.time <
              Duration(minutes: 5).inMilliseconds);

  Future<AppNameSignature> get clientForgeSignature async {
    if (!hasValidForgeSignature) {
      AppNameSignature sig = AppNameSignature.newSignature();
      await setSelfAtomic<AppNameSignature>(
          (u) => u!.copyWith(serverSignatures: [
                ...serverSignatures.where((i) =>
                    DateTime.timestamp().millisecondsSinceEpoch - i.time >
                    Duration(minutes: 10).inMilliseconds),
                sig
              ]));
      return sig;
    }

    return anyValidForgeSignature;
  }

  @override
  List<FireModel<ModelCrud>> get childModels => [];
}
