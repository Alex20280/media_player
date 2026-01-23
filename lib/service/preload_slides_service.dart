import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';

class PreloadSlidesService {

  PreloadSlidesService();

  final Map<String, ui.Image> _cache = {};
  
  String _getKey(String path) => path;

  Future<ui.Image?> preCacheSlide(File? file, String? filename) async {
    if (file == null || filename == null) return null;
    
    final fileData = await compute(_readSingleFile, file);
    if (fileData == null) return null;

    try {
      final codec = await ui.instantiateImageCodec(fileData);
      final frame = await codec.getNextFrame();
      final newImage = frame.image;
      
      dispose(); 
      
      _cache[_getKey(file.path)] = newImage;
      codec.dispose();
      
      return newImage;
    } catch (e) {
      print("Error decoding image: $e");
      return null;
    }
  }

  static Uint8List? _readSingleFile(File file) {
    try {
      if (!file.existsSync()) return null;
      return file.readAsBytesSync();
    } catch (e) {
      return null;
    }
  }

  ui.Image? getDecodedImage(String filePath) {
    return _cache[_getKey(filePath)] ?? _cache.values.firstOrNull;
  }

  void dispose() {
    for (final img in _cache.values) {
      img.dispose();
    }
    _cache.clear();
  }
}