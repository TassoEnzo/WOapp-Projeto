import 'package:permission_handler/permission_handler.dart';

class PermissoesServico {
  static Future<bool> solicitarPermissoes() async {
    var fotos = await Permission.photos.request();
    var storage = await Permission.storage.request();
    var camera = await Permission.camera.request();
    return camera.isGranted && (fotos.isGranted || storage.isGranted);
  }
}