import 'package:occult/util/tasks.dart';
import 'package:universal_io/io.dart';

class TInstallLibMagick extends OTaskJob {
  final String app;

  TInstallLibMagick(this.app) : super("Install libmagick to ${app}_server");

  @override
  Future<void> run() => add(TaskDownload(
      "https://raw.githubusercontent.com/ArcaneArts/multimedia/refs/heads/main/lib/libraries/libimage_magick_ffi.so",
      "${app}_server${Platform.pathSeparator}ffi${Platform.pathSeparator}libimage_magick_ffi.so"));
}
