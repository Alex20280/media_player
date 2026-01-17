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
        final track = status.track;
        _currentTrack = track;

        final fileType = FileTypeX.fromString(track?.track.type);
        final file = track?.file;

        if ((fileType == FileType.video || fileType == FileType.audio) && file != null) {
          await _playerManager.addTrackToPlaylist(file);
        }

        if (fileType == FileType.slide) {
          await _preloadSlidesService.preCacheSlide(file, track?.track.filename);
        }

        emit(RecentTrackSuccess(currentTrack: _currentTrack));

      } else if (status is TrackNotFound) {
        emit(RecentTrackError('File not found'));

      } else if (status is TrackError) {
        emit(RecentTrackError('Failed to load track: ${status.error}'));
      }

    } catch (e, stackTrace) {
      emit(RecentTrackError('Unexpected error: $e'));
    } finally {
      event.completer?.complete();
    }
  }
}