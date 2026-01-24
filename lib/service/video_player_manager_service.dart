import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class ScheduleTrackPlayerService with ChangeNotifier {
  ScheduleTrackPlayerService() {
    _videoController = VideoController(
      _player,
      configuration: const VideoControllerConfiguration(
        enableHardwareAcceleration: true,
        androidAttachSurfaceAfterVideoParameters: true,
      ),
    );
    _player.setPlaylistMode(PlaylistMode.none);
  }

  bool isFirstRun = true;

  final Player _player = Player(
    configuration: const PlayerConfiguration(
      bufferSize: 32 * 1024 * 1024,
    ),
  );

  late final VideoController _videoController;
  File? get currentTrack => _currentTrack;
  VideoController get videoController => _videoController;
  File? _currentTrack;
  bool _isChangingTrack = false;
  StreamSubscription? _completedSubscription;
  final List<String> _addedTrackPaths = [];

  Future<void> addTrackToPlaylist(File file) async {
    final path = file.path;
    if (_addedTrackPaths.contains(path)) return;
    _addedTrackPaths.add(path);
  }

  Future<void> playTrack(
    File file,
    Duration? seekPosition,
    String? tag,
    String? sk,
    String? playlistSk,
    String? filename,
    String? type,
    String? title,
    String? artist,
    String? campaignSk,
  ) async {
    if (_isChangingTrack) return;
    _isChangingTrack = true;

    try {
      _currentTrack = file;

      await _player.open(Media(file.path), play: false);

      if (seekPosition != null && seekPosition > Duration.zero) {
        await _player.seek(seekPosition);
      } else if (isFirstRun) {
        isFirstRun = false;
      }

      await _player.play();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("Error playing track: $e");
    } finally {
      _isChangingTrack = false;
    }
  }

  Future<void> pauseForSlide() async {
    await _player.stop();
  }

  Future<void> stopAndClear() async {
    await _player.stop();
  }

  Future<void> setVolume(double volume) {
    return _player.setVolume(volume);
  }

  @override
  void dispose() {
    _player.dispose();
    _completedSubscription?.cancel();
    _currentTrack = null;
    super.dispose();
  }
}