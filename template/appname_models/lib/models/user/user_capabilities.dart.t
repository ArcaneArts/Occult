import 'package:dart_mappable/dart_mappable.dart';
import 'package:fire_crud/fire_crud.dart';

part 'user_capabilities.mapper.dart';

@MappableClass()
class AppNameUserCapabilities with AppNameUserCapabilitiesMappable, ModelCrud {
  AppNameUserCapabilities();

  @override
  List<FireModel<ModelCrud>> get childModels => [];
}
