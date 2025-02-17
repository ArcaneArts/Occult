/*
 * Copyright (c) 2024. Crucible Labs Inc.
 *
 * Crucible is a closed source project developed by Crucible Labs Inc. 
 * Do not copy, share distribute or otherwise allow this source file 
 * to leave hardware approved by Crucible Labs Inc. unless otherwise 
 * approved by Crucible Labs Inc.
 */

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
