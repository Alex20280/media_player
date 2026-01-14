import 'package:flutter/cupertino.dart';
import 'package:media_kit_video/media_kit_video.dart';

class MediaPlayerWrapper extends StatefulWidget {
  final VideoController controller;

  const MediaPlayerWrapper({
    super.key,
    required this.controller,
  });

  @override
  State<MediaPlayerWrapper> createState() => _MediaPlayerWrapperState();
}

class _MediaPlayerWrapperState extends State<MediaPlayerWrapper> {

  @override
  Widget build(BuildContext context) {
    return Video(controller: widget.controller, controls: null);
  }
}
