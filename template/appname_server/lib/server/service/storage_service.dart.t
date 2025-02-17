import 'package:fire_api/fire_api.dart';
import 'package:fire_api_dart/fire_api_dart.dart';

class StorageService {
  late FireStorage storage;

  Future<void> start() async {
    storage = await GoogleCloudFireStorage.create();
  }

  FireStorageRef bucket(String bucket) => storage.bucket(bucket);

  FireStorageRef ref(String bucket, String path) => storage.ref(bucket, path);
}
