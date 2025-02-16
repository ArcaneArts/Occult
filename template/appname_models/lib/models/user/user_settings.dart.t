import 'package:appname_models/appname_models.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:fire_crud/fire_crud.dart';

part 'user_settings.mapper.dart';

@MappableClass()
class OccultUserSettings with OccultUserSettingsMappable, ModelCrud {
  final String? theme;
  final List<OccultSignature> serverSignatures;
  final String? aiModel;

  OccultUserSettings({
    this.theme,
    this.serverSignatures = const [],
    this.aiModel,
  });

  bool get hasValidForgeSignature => serverSignatures.any((i) =>
      i.session == OccultSignature.sessionId &&
      DateTime.timestamp().millisecondsSinceEpoch - i.time <
          Duration(minutes: 5).inMilliseconds);

  OccultSignature get anyValidForgeSignature =>
      serverSignatures.firstWhere((i) =>
          i.session == OccultSignature.sessionId &&
          DateTime.timestamp().millisecondsSinceEpoch - i.time <
              Duration(minutes: 5).inMilliseconds);

  Future<OccultSignature> get clientForgeSignature async {
    if (!hasValidForgeSignature) {
      OccultSignature sig = OccultSignature.newSignature();
      await setSelfAtomic<OccultSignature>(
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
