import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/model/playing_track_model.dart';
import 'package:media_player/model/track_status.dart';
import 'package:media_player/service/preload_slides_service.dart';
import 'package:media_player/service/video_player_manager_service.dart';
import 'package:media_player/use_case/get_current_track_use_case.dart';
import 'get_recent_track_event.dart';
import 'get_recent_track_state.dart';

class GetRecentTrackBloc extends Bloc<GetRecentTrackEvent, GetRecentTrackState> {
  final GetCurrentTrackUseCase _useCase;
  final ScheduleTrackPlayerService _playerManager;
  final PreloadSlidesService _preloadSlidesService;

  PlayingMediaModel? _currentTrack;

  GetRecentTrackBloc(
      this._useCase,
      this._playerManager,
      this._preloadSlidesService,
      ) : super(RecentTrackInitial()) {
    on<LoadLocalTrackEvent>(_onLoadLocalTrack);
  }

  Future<void> _onLoadLocalTrack(
      LoadLocalTrackEvent event,
      Emitter<GetRecentTrackState> emit,
      ) async {
    try {
      final status = await _useCase.receiveTrack();

      if (status is TrackPlaying) {
        final newTrack = status.track;
        _currentTrack = newTrack;
        final fileType = FileTypeX.fromString(newTrack?.track.type);

        if (fileType == FileType.slide) {
          await _preloadSlidesService.preCacheSlide(newTrack?.file, newTrack?.track.filename);
          
          emit(RecentTrackSuccess(currentTrack: _currentTrack));

          final nextVideoFile = _useCase.peekNextVideo();
          if (nextVideoFile != null) {
             _playerManager.preloadVideo(nextVideoFile);
          }

        } else if (fileType == FileType.video || fileType == FileType.audio) {
          
          if (newTrack?.file != null) {
               await _playerManager.playTrack(
                newTrack!.file!,
                Duration(seconds: newTrack.seekPosition.toInt()),
                newTrack.tag,
                newTrack.track.sk,
                newTrack.track.playlistSk,
                newTrack.track.filename,
                newTrack.track.type,
                newTrack.track.title,
                newTrack.track.artist,
                newTrack.track.campaignSk,
              );
          }
          emit(RecentTrackSuccess(currentTrack: _currentTrack));
        }

      } else if (status is TrackOutOfSchedule) {
        await _playerManager.stopAndClear();
        emit(RecentTrackOutOfSchedule());

      } else if (status is TrackNotFound) {
        await _playerManager.stopAndClear();
        emit(RecentTrackError('File not found'));

      } else if (status is TrackError) {
        emit(RecentTrackError('Error: ${status.error}'));
      }

    } catch (e) {
       if (kDebugMode) print("❌ Bloc Error: $e");
       emit(RecentTrackError('Unexpected error: $e'));
    } finally {
      event.completer?.complete();
    }
  }
}