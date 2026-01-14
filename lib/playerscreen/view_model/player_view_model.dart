import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:media_player/use_case/get_current_track_use_case.dart';
import 'package:media_player/getrecenttrackbloc/get_recent_track_bloc.dart';
import 'package:media_player/getrecenttrackbloc/get_recent_track_event.dart';
import 'package:media_player/playerscreen/view_model/player_view_state.dart';
import 'package:media_player/model/playing_track_model.dart';
import 'package:media_player/service/preload_slides_service.dart';
import 'package:media_player/model/track_model.dart';
import 'package:media_player/service/video_player_manager_service.dart';

class PlayerViewModel extends Cubit<PlayerViewState> {
  PlayerViewModel({
    required GetCurrentTrackUseCase getCurrentTrackUseCase,
    required PreloadSlidesService preloadSlidesService,
  })  : _getCurrentTrackUseCase = getCurrentTrackUseCase,
        _preloadSlidesService = preloadSlidesService,
        super(const PlayerViewState()) {
    _initialize();
  }

  final GetCurrentTrackUseCase _getCurrentTrackUseCase;
  final PreloadSlidesService _preloadSlidesService;

  late final GetRecentTrackBloc _getTrackBloc;
  late final ScheduleTrackPlayerService _scheduleTrackPlayerService;

  GetRecentTrackBloc get getTrackBloc => _getTrackBloc;
  ScheduleTrackPlayerService get scheduleTrackPlayerService => _scheduleTrackPlayerService;
  PreloadSlidesService get preloadSlidesService => _preloadSlidesService;

  void _initialize() {
    _scheduleTrackPlayerService = GetIt.I<ScheduleTrackPlayerService>();

    _getTrackBloc = GetRecentTrackBloc(
      _getCurrentTrackUseCase,
      _scheduleTrackPlayerService,
      _preloadSlidesService,
    )..add(LoadLocalTrackEvent());

    _scheduleTrackPlayerService.addListener(_onPlayerManagerUpdate);
  }

  void _onPlayerManagerUpdate() {
    if (!isClosed) {
      emit(state.copyWith(updateTrigger: DateTime.now().millisecondsSinceEpoch));
    }
  }


  Future<void> onTrackChanged(PlayingMediaModel track) async {
    final file = track.file;
    if (file == null) {
      return;
    }

    final fileType = FileTypeX.fromString(track.track.type);

    if (fileType == FileType.slide) {
      await scheduleTrackPlayerService.pauseForSlide();
      return;
    }

    if (fileType != FileType.video && fileType != FileType.audio) {
      return;
    }


    if (scheduleTrackPlayerService.currentTrack?.path == file.path) {

      return;
    }

    final seekDuration = Duration(
      milliseconds: ((track.seekPosition ?? 0) * 1000).round(),
    );

    await scheduleTrackPlayerService.playTrack(
      file,
      seekDuration,
      track.tag,
      track.track.playlistSk,
      track.track.sk,
      track.track.filename,
      track.track.type,
      track.track.title,
      track.track.artist,
      track.track.campaignSk,
    );
  }

  @override
  Future<void> close() {
    _scheduleTrackPlayerService.removeListener(_onPlayerManagerUpdate);
    _getTrackBloc.close();
    return super.close();
  }
}