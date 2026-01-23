import 'dart:io';
import 'package:media_player/model/track_model.dart'; 

class PlayingMediaModel implements PlayingItem {
  final TrackModel track;
  final File? file;
  final double seekPosition;
  final String tag;

  PlayingMediaModel({
    required this.track,
    required this.file,
    required this.seekPosition,
    required this.tag,
  });
}

abstract class PlayingItem {}

enum FileType { audio, video, slide, unknown }

extension FileTypeX on FileType {
  String get value {
    switch (this) {
      case FileType.audio:
        return "audio";
      case FileType.video:
        return "video";
      case FileType.slide:
        return "slide";
      case FileType.unknown:
        return "unknown";
    }
  }

  static FileType fromString(String? value) {
    switch (value) {
      case "audio":
        return FileType.audio;
      case "video":
        return FileType.video;
      case "slide":
        return FileType.slide;
      default:
        return FileType.unknown;
    }
  }
}