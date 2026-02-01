import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:media_player/model/current_track_model.dart';
import 'package:media_player/model/playing_track_model.dart';
import 'package:media_player/service/playing_tracks_service.dart';
import 'package:media_player/model/track_model.dart';
import 'package:media_player/model/track_status.dart';

class GetCurrentTrackUseCase {
  GetCurrentTrackUseCase(
    this._playingTracksService,
  );

  final PlayingTracksService _playingTracksService;
  
  void Function(TrackStatus)? _onTrackChanged;

  void setTrackChangedCallback(void Function(TrackStatus) callback) {
    _onTrackChanged = callback;
  }

  void _notifyTrackChanged(TrackStatus status) {
    _onTrackChanged?.call(status);
  }

  List<File> _tracks = [];
  List<File> _slides = [];
  int _trackIndex = 0;
  int _slideIndex = 0;
  MediaTurn _turn = MediaTurn.track;
  bool _initialized = false;

  File? peekNextVideo() {
    if (_tracks.isEmpty) return null;
    int nextIndex = _trackIndex; 
    if (nextIndex >= _tracks.length) nextIndex = 0;
    return _tracks[nextIndex];
  }

  Future<TrackStatus> receiveTrack() async {
    try {
      await _initMedia();

      final next = _getNextFileWithType();
      if (next == null) {
        final status = const TrackNotFound();
        _notifyTrackChanged(status);
        return status;
      }

      final (file, fileType) = next;

      final trackResult = _buildCurrentTrack(file, fileType);
      
      final playingTrack = await _createPlayingTrackModel(
        trackResult,
        file,
      );

      if (playingTrack == null) {
        final status = TrackError('Failed to create PlayingMediaModel');
        _notifyTrackChanged(status);
        return status;
      }

      final status = TrackPlaying(playingTrack);
      _notifyTrackChanged(status);
      return status;
    } catch (e) {
      final status = TrackError(e);
      _notifyTrackChanged(status);
      return status;
    }
  }

  CurrentTrackModel _buildCurrentTrack(File file, FileType type) {
    return CurrentTrackModel(
      track: TrackModel(
        filename: p.basename(file.path),
        type: type.name,
        duration: 0,
        artist: '',
        source: '',
        sk: '',
        pk: '',
        playlistSk: '',
        title: '',
      ),
    );
  }

  (File, FileType)? _getNextFileWithType() {
    if (_tracks.isEmpty && _slides.isEmpty) return null;

    for (int i = 0; i < 2; i++) {
      if (_turn == MediaTurn.track && _tracks.isNotEmpty) {
        if (_trackIndex >= _tracks.length) _trackIndex = 0;
        final file = _tracks[_trackIndex++];
        _turn = MediaTurn.slide; 
        return (file, FileType.video);
      }
      if (_turn == MediaTurn.slide && _slides.isNotEmpty) {
        if (_slideIndex >= _slides.length) _slideIndex = 0;
        final file = _slides[_slideIndex++];
        _turn = MediaTurn.track; 
        return (file, FileType.slide);
      }
      _turn = _turn == MediaTurn.track ? MediaTurn.slide : MediaTurn.track;
    }
    return null;
  }

  Future<PlayingMediaModel?> _createPlayingTrackModel(
      CurrentTrackModel trackResult, File file) async {
    return PlayingMediaModel(
        track: trackResult.track, file: file, seekPosition: 0, tag: "tag");
  }

  Future<void> _initMedia() async {
    if (_initialized) return;

    final basePath = (await getApplicationDocumentsDirectory()).path;
    final tracksDir = Directory(p.join(basePath, 'tracks'));
    final slidesDir = Directory(p.join(basePath, 'slides'));

    if (!await tracksDir.exists()) await tracksDir.create(recursive: true);
    if (!await slidesDir.exists()) await slidesDir.create(recursive: true);

    if (await tracksDir.exists()) {
      _tracks = tracksDir
          .listSync()
          .whereType<File>()
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
    }

    if (await slidesDir.exists()) {
      _slides = slidesDir
          .listSync()
          .whereType<File>()
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
    }
    _initialized = true;
  }
}

enum MediaTurn { track, slide }