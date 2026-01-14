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

