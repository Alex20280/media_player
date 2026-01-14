import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';

class PreloadSlidesService {

  PreloadSlidesService();

  final Map<String, ui.Image> _cache = {};
  Map<String, ui.Image> get cache => _cache;

  Future<ui.Image?> preCacheSlide(File? file, String? filename) async {
    if (filename == null) {
      return null;
    }

    if (file == null) {
       return null;
    }

    final fileData = await compute(_readSingleFile, file);
    if (fileData == null) {
      return null;
    }
    ui.Image? image;

    try {
      final codec = await ui.instantiateImageCodec(fileData);
      final frame = await codec.getNextFrame();

      image = frame.image;
      _cache.clear();
      _cache[filename] = image;

      codec.dispose();
    } catch (e, stackTrace) {
     }

    return image;
  }

  static Uint8List? _readSingleFile(File file) {
    try {
      return file.readAsBytesSync();
    } catch (e) {
      return null;
    }
  }

  ui.Image? getDecodedImage(String filePath) {
    return _cache.values.firstOrNull;
  }

  void dispose() {
    for (final img in _cache.values) {
      img.dispose();
    }
    _cache.clear();
  }
}
