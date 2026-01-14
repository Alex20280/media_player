import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/use_case/get_current_track_use_case.dart';
import 'package:media_player/getrecenttrackbloc/get_recent_track_event.dart';
import 'package:media_player/getrecenttrackbloc/get_recent_track_state.dart';
import 'package:media_player/model/playing_track_model.dart';
import 'package:media_player/service/preload_slides_service.dart';
import 'package:media_player/model/track_model.dart';
import 'package:media_player/model/track_status.dart';
import 'package:media_player/service/video_player_manager_service.dart';


class GetRecentTrackBloc extends Bloc<GetRecentTrackEvent, GetRecentTrackState> {
  final GetCurrentTrackUseCase getCurrentlyPlayingTrackUseCase;
  final ScheduleTrackPlayerService _playerManager;
  PlayingMediaModel? _currentTrack;
  final PreloadSlidesService _preloadSlidesService;

  GetRecentTrackBloc(
      this.getCurrentlyPlayingTrackUseCase,
      this._playerManager,
      this._preloadSlidesService,
      ) : super(RecentTrackInitial()) {
    on<LoadLocalTrackEvent>(_onLoadLocalTrack);
    on<_InternalTrackChangedEvent>(_onInternalTrackChanged);
  }

  Future<void> _onLoadLocalTrack(
      LoadLocalTrackEvent event,
      Emitter<GetRecentTrackState> emit,
      ) async {
    emit(RecentTrackLoading());

    getCurrentlyPlayingTrackUseCase.setTrackChangedCallback((status) {
      add(_InternalTrackChangedEvent(status));
    });
    try {
      final status = await getCurrentlyPlayingTrackUseCase.startPeriodicWork();

      if (status is TrackPlaying) {
        if (FileTypeX.fromString(status.track?.track.type) == FileType.video||
            FileTypeX.fromString(status.track?.track.type) == FileType.audio){
          final track = status.track;
          _currentTrack = track;

          final file = track?.file;
          if (file != null && _playerManager.currentTrack == null) {
            await _playerManager.addTrackToPlaylist(file);
          }
        }

        final fileType = FileTypeX.fromString(status.track?.track.type);
        if (fileType == FileType.slide) {
          await _preloadSlidesService.preCacheSlide(status.track?.file, status.track?.track.filename);
        }
        emit(RecentTrackSuccess(currentTrack: _currentTrack));
      } else if (status is TrackOutOfSchedule) {
        emit(RecentTrackOutOfSchedule());
      } else if (status is TrackNotFound) {
        emit(RecentTrackError('File not found'));
      } else if (status is TrackError) {
        emit(RecentTrackError('Failed to load track: ${status.error}'));
      }
    } catch (e, stackTrace) {
      emit(RecentTrackError('Unexpected error: $e'));
    }
  }

  void _onInternalTrackChanged(
      _InternalTrackChangedEvent event,
      Emitter<GetRecentTrackState> emit,
      ) async {
    final status = event.status;

    if (status is TrackPlaying) {
      final track = status.track;
      _currentTrack = track;
      final file = track?.file;

      final fileType = FileTypeX.fromString(track?.track.type);
      if (fileType == FileType.slide) {
        await _preloadSlidesService.preCacheSlide(track?.file, track?.track.filename);
      } else if  (fileType == FileType.video|| fileType == FileType.audio) {
        if (file != null) {
          await _playerManager.addTrackToPlaylist(file);
        }
      }
      if (state is RecentTrackSuccess) {
        emit(RecentTrackSuccess(currentTrack: _currentTrack));
      }
    }
    else if (status is TrackOutOfSchedule) {
      _currentTrack = null;
      emit(RecentTrackOutOfSchedule());
    }
  }
}

class _InternalTrackChangedEvent extends GetRecentTrackEvent {
  final TrackStatus status;
  _InternalTrackChangedEvent(this.status);
}