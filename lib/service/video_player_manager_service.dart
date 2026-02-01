import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class ScheduleTrackPlayerService with ChangeNotifier, WidgetsBindingObserver {
  
  ScheduleTrackPlayerService() {
    WidgetsBinding.instance.addObserver(this);

    _videoController = VideoController(
      _player,
      configuration: const VideoControllerConfiguration(
        enableHardwareAcceleration: true,
        androidAttachSurfaceAfterVideoParameters: false, 
      ),
    );
    _player.setPlaylistMode(PlaylistMode.none);
  }

  final Player _player = Player(
    configuration: const PlayerConfiguration(
      bufferSize: 32 * 1024 * 1024, 
      vo: 'gpu',
    ),
  );

  late final VideoController _videoController;
  VideoController get videoController => _videoController;
  
  String? _preloadedPath; 

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _player.pause();
    }
  }

  Future<void> preloadVideo(File file) async {
    if (_preloadedPath == file.path) return;
    
    try {
      if (kDebugMode) print("⏳ Preloading: ${file.path.split('/').last}");
      _preloadedPath = file.path;
      await _player.open(Media(file.path), play: false);
    } catch (e) {
      print("Preload error: $e");
    }
  }

  Future<void> playTrack(
    File file,
    Duration? seekPosition, 
    String? tag, String? sk, String? playlistSk, String? filename, String? type, String? title, String? artist, String? campaignSk,
  ) async {
    try {
      bool isPreloaded = _preloadedPath == file.path;
      
      if (isPreloaded) {
        if (kDebugMode) print("🚀 Instant Play: ${file.path.split('/').last}");
        _preloadedPath = null;
        await _player.play();
      } else {
        if (kDebugMode) print("▶️ Normal Play: ${file.path.split('/').last}");
        await _player.open(Media(file.path), play: true);
      }
      if (seekPosition != null && seekPosition > Duration.zero) {
           await _player.seek(seekPosition);
      }

      notifyListeners();
    } catch (e) {
      print("Play error: $e");
    }
  }

  Future<void> pauseForSlide() async {
    await _player.pause();
  }

  Future<void> stopAndClear() async {
    await _player.stop();
    _preloadedPath = null;
  }
  
  Future<void> setVolume(double volume) => _player.setVolume(volume);

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _player.dispose();
    super.dispose();
  }
}