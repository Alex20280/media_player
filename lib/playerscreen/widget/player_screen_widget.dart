import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_player/getrecenttrackbloc/get_recent_track_bloc.dart';
import 'package:media_player/getrecenttrackbloc/get_recent_track_state.dart';
import 'package:media_player/playerscreen/view_model/player_view_model.dart';
import 'package:media_player/model/track_model.dart';

class PlayerScreenWidget extends StatefulWidget {
  final VoidCallback? onOutOfSchedule;

  const PlayerScreenWidget({super.key, this.onOutOfSchedule});

  @override
  State<PlayerScreenWidget> createState() => _PlayerScreenWidgetState();
}

class _PlayerScreenWidgetState extends State<PlayerScreenWidget> {
  late final PlayerViewModel _viewModel;
  late final GetRecentTrackBloc _getTrackBloc;
  late final StreamSubscription _systemSoundsSubscription;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<PlayerViewModel>();
    _getTrackBloc = _viewModel.getTrackBloc;

  }


  @override
  void dispose() {
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

              if (state is RecentTrackSuccess && state.currentTrack != null) {
                context.read<PlayerViewModel>().onTrackChanged(state.currentTrack!);
              }
            },
          ),
        ],
        child: BlocBuilder<GetRecentTrackBloc, GetRecentTrackState>(
          builder: (context, state) {
            return Scaffold(
              backgroundColor: Colors.black,
              body: _buildContent(context, state),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, GetRecentTrackState state) {
    if (state is RecentTrackLoading) {
      return _buildLoadingState();
    }

    if (state is RecentTrackError) {
      return _buildErrorState();
    }

    if (state is RecentTrackSuccess) {
      return _buildTrackState(context, state);
    }

    return const SizedBox.shrink();
  }

  Widget _buildLoadingState() => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
        SizedBox(height: 16),
        Text(
          "Wait a moment...",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    ),
  );

  Widget _buildErrorState() => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline, color: Colors.red, size: 64),
        SizedBox(height: 16),
        Text(
          'Error loading track',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    ),
  );

  Widget _buildTrackState(BuildContext context, RecentTrackSuccess state) {
    final track = state.currentTrack;
    final file = track?.file;

    if (file == null) {
      return const Center(child: Text('No file', style: TextStyle(color: Colors.white)));
    }

    final viewModel = context.read<PlayerViewModel>();
    final service = viewModel.scheduleTrackPlayerService;
    final fileType = FileTypeX.fromString(track?.track.type);

    final ui.Image? slideImage = (fileType == FileType.slide)
        ? viewModel.preloadSlidesService.getDecodedImage(file.path)
        : null;

    final videoController = service.videoController;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: MediaPlayerWrapper(
            key: const ValueKey('video_player_layer'),
            controller: videoController,
          ),
        ),

        if (fileType == FileType.slide)
          Positioned.fill(
            key: ValueKey('slide_layer_${file.path}'),
            child: Container(
              color: Colors.black,
              child: (slideImage != null)
                  ? RawImage(
                image: slideImage,
                fit: BoxFit.contain,
              )
                  : Image.asset(
                'assets/no_image.jpg',
                fit: BoxFit.contain,
              ),
            ),
          ),

        if (fileType == FileType.audio)
          const Positioned.fill(
            child: ColoredBox(
              color: Colors.black,
              child: Center(
                child: Icon(
                  Icons.music_note,
                  color: Colors.white,
                  size: 80,
                ),
              ),
            ),
          ),

        ListenableBuilder(
          listenable: service,
          builder: (context, _) {
            return Visibility(
              visible: service.isChangingTrack,
              child: Container(
                color: Colors.black,
                width: double.infinity,
                height: double.infinity,
              ),
            );
          },
        ),

        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black54],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filename: ${file.path.split('/').last}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Artist: ${track?.track.artist ?? '-'}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Track: ${track?.track.source ?? '-'}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class MediaPlayerWrapper extends StatelessWidget {
  final VideoController controller;

  const MediaPlayerWrapper({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Video(
      controller: controller,
      fit: BoxFit.contain,
    );
  }
}
