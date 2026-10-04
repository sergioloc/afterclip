import 'package:flutter/services.dart';

class GalleryService {
  static const _channel = MethodChannel('afterclip/gallery');

  Future<void> saveVideo(String path) async {
    await _channel.invokeMethod('saveVideo', {'path': path});
  }
}
