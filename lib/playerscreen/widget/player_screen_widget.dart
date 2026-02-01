import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_player/getrecenttrackbloc/get_recent_track_bloc.dart';
import 'package:media_player/getrecenttrackbloc/get_recent_track_state.dart';
import 'package:media_player/playerscreen/view_model/player_view_model.dart';
import 'package:media_player/model/playing_track_model.dart';

class PlayerScreenWidget extends StatefulWidget {
  final VoidCallback? onOutOfSchedule;

  const PlayerScreenWidget({super.key, this.onOutOfSchedule});

  @override
  State<PlayerScreenWidget> createState() => _PlayerScreenWidgetState();
}

class _PlayerScreenWidgetState extends State<PlayerScreenWidget> {
  late final PlayerViewModel _viewModel;
  late final GetRecentTrackBloc _getTrackBloc;
  
  ui.Image? _lastSlideImage;
  bool _showOverlay = false;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<PlayerViewModel>();
    _getTrackBloc = _viewModel.getTrackBloc;
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _getTrackBloc),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<GetRecentTrackBloc, GetRecentTrackState>(
            listener: (context, state) {
              if (state is RecentTrackOutOfSchedule) {
                widget.onOutOfSchedule?.call();
              }
            },
          ),
        ],
        child: BlocBuilder<GetRecentTrackBloc, GetRecentTrackState>(
          builder: (context, state) {
            if (state is RecentTrackError) {
              return _buildErrorState(state.message);
            }
            if (state is RecentTrackSuccess) {
              return _buildTrackState(context, state);
            }
            return _buildLoadingState();
          },
        ),
      ),
    );
  }

  Widget _buildTrackState(BuildContext context, RecentTrackSuccess state) {
    final track = state.currentTrack;
    final file = track?.file;
    if (file == null) return Container(color: Colors.black);

    final fileType = FileTypeX.fromString(track?.track.type);
    final controller = _viewModel.scheduleTrackPlayerService.videoController;

    
    if (fileType == FileType.slide) {
      _hideTimer?.cancel();
      _lastSlideImage = _viewModel.preloadSlidesService.getDecodedImage(file.path);
      _showOverlay = true;
    } else {
      if (_showOverlay) {
        _hideTimer?.cancel();
        _hideTimer = Timer(const Duration(milliseconds: 400), () {
          if (mounted) {
            setState(() {
              _showOverlay = false;
            });
          }
        });
      }
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: Colors.black,
          child: Video(
            controller: controller,
            fit: BoxFit.contain,
            controls: NoVideoControls,
            pauseUponEnteringBackgroundMode: false,
            resumeUponEnteringForegroundMode: true,
          ),
        ),

        if (_showOverlay && _lastSlideImage != null)
          Container(
            color: Colors.black,
            width: double.infinity,
            height: double.infinity,
            child: RawImage(
              image: _lastSlideImage,
              fit: BoxFit.contain,
            ),
          ),

        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: Colors.black54,
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Artist: ${track?.track.artist ?? '-'}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Track: ${track?.track.title ?? file.path.split('/').last}',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() => const Center(child: CircularProgressIndicator());
  Widget _buildErrorState(String msg) => Center(child: Text(msg, style: const TextStyle(color: Colors.red)));
}