import 'package:dart_mappable/dart_mappable.dart';
import 'package:fire_crud/fire_crud.dart';

part 'user_capabilities.mapper.dart';

@MappableClass()
class OccultUserCapabilities with OccultUserCapabilitiesMappable, ModelCrud {
  final int credits;

  OccultUserCapabilities({
    this.credits = 0,
  });

  @override
  List<FireModel<ModelCrud>> get childModels => [];
}
