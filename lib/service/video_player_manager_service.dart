import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

/*
class ScheduleTrackPlayerService with ChangeNotifier {
  ScheduleTrackPlayerService() {
    _videoController = VideoController(_player);
    _player.setPlaylistMode(PlaylistMode.none);
  }

  bool isFirstTrack = false;

  final Player _player = Player(
    configuration: const PlayerConfiguration(
      bufferSize: 32 * 1024 * 1024,
    ),
  );
  late final VideoController _videoController;

  File? get currentTrack => _currentTrack;
  VideoController get videoController => _videoController;

  bool get isChangingTrack => _isChangingTrack;

  File? _currentTrack;
  bool _isChangingTrack = false;
  StreamSubscription? _completedSubscription;

  Future<void> addTrackToPlaylist(File file) async {
    try {
      _currentTrack = file;
      final media = Media(file.path);

      await _player.open(media, play: false);

      await _player.play();

    } catch (e, stackTrace) {
     }
  }

  Future<void> pauseForSlide() async {
    await stopAndClear();
  }

  Future<void> stopAndClear() async {
    try {
      await _player.stop();
    } catch (e, stackTrace) {
    }
  }

  Future<void> playTrack(File file, Duration? seekPosition, String? tag, String? sk, String? playlistSk, String? filename, String? type, String? title, String? artist, String? campaignSk) async {
    if (_isChangingTrack) {
      return;
    }

    _isChangingTrack = true;
    notifyListeners();

    try {
      await _player.play();

      if (seekPosition != null && seekPosition > Duration.zero) {
        await _player.seek(seekPosition);
      }


    } catch (e, stackTrace) {
     } finally {
      _isChangingTrack = false;
      notifyListeners();
    }
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
}*/


class ScheduleTrackPlayerService with ChangeNotifier {
  ScheduleTrackPlayerService() {
    _videoController = VideoController(_player);
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
  var index = 0;

  Future<void> addTrackToPlaylist(File file) async {
    final path = file.path;

    if (_addedTrackPaths.contains(path)) {
      return;
    }
    _addedTrackPaths.add(path);

    try {
      final media = Media(path);
      await _player.add(media);
    } catch (e, stackTrace) {
     _addedTrackPaths.remove(path);
    }
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
      final playlist = _player.state.playlist;
      if (playlist.medias.isEmpty) return;

      final index = _findTrackIndex(playlist, file);
      if (index == -1) return;

      _currentTrack = file;

      await _player.pause();
      await _player.jump(index);
      await _waitForPlayerReady(index);
      await _player.play();
      await Future.delayed(const Duration(milliseconds: 300));

      //Сделал костыль чтобы для первого видео применять seek
      if (isFirstRun) {
        await _player.seek(const Duration(seconds: 5));
        isFirstRun = false;
      }

      notifyListeners();
    } catch (e) {
    } finally {
      _isChangingTrack = false;
    }
  }

  Future<void> pauseForSlide() async {
    await stopAndClear();
  }

  Future<void> stopAndClear() async {
    try {
      await _player.stop();
    } catch (e, stackTrace) {
    }
  }

  Future <void> setVolume(double volume) {
    return _player.setVolume(volume);
  }

  int _findTrackIndex(Playlist playlist, File file) {
    return playlist.medias.indexWhere((media) {
      final mediaName = media.uri.split('/').last;
      final fileName = file.path.split('/').last;
      return mediaName == fileName;
    });
  }

  Future<void> _waitForPlayerReady(int expectedIndex) async {
    int attempts = 0;
    while ((_player.state.buffering ||
        _player.state.duration == Duration.zero ||
        _player.state.playlist.index != expectedIndex) &&
        attempts < 20) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
  }

  @override
  void dispose() {
    _player.dispose();
    _completedSubscription?.cancel();
    _currentTrack = null;
    super.dispose();
  }
}