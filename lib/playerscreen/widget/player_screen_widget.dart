import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_player/getrecenttrackbloc/get_recent_track_bloc.dart';
import 'package:media_player/getrecenttrackbloc/get_recent_track_state.dart';
import 'package:media_player/playerscreen/view_model/player_view_model.dart';
import 'package:media_player/model/playing_track_model.dart'; 

class MediaPlayerWrapper extends StatelessWidget {
  final VideoController controller;

  const MediaPlayerWrapper({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Video(
        controller: controller,
        fit: BoxFit.contain,
        controls: NoVideoControls, 
      ),
    );
  }
}

class PlayerScreenWidget extends StatefulWidget {
  final VoidCallback? onOutOfSchedule;

  const PlayerScreenWidget({super.key, this.onOutOfSchedule});

  @override
  State<PlayerScreenWidget> createState() => _PlayerScreenWidgetState();
}

class _PlayerScreenWidgetState extends State<PlayerScreenWidget> {
  late final PlayerViewModel _viewModel;
  late final GetRecentTrackBloc _getTrackBloc;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<PlayerViewModel>();
    _getTrackBloc = _viewModel.getTrackBloc;
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
    if (file == null) return const SizedBox();

    final fileType = FileTypeX.fromString(track?.track.type);
    
    final viewModel = context.read<PlayerViewModel>();
    final controller = viewModel.scheduleTrackPlayerService.videoController;

    ui.Image? slideImage;
    if (fileType == FileType.slide) {
      slideImage = viewModel.preloadSlidesService.getDecodedImage(file.path);
    }

    final bool showSlide = fileType == FileType.slide;

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: Colors.black,
          child: Video(
            controller: controller,
            fit: BoxFit.contain,
            controls: NoVideoControls,
          ),
        ),

        if (showSlide)
          Container(
            color: Colors.black,
            width: double.infinity,
            height: double.infinity,
            child: slideImage != null
                ? RawImage(
                    image: slideImage,
                    fit: BoxFit.contain,
                  )
                : const SizedBox(),
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