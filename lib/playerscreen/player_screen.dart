import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:media_player/use_case/get_current_track_use_case.dart';
import 'package:media_player/playerscreen/view_model/player_view_model.dart';
import 'package:media_player/playerscreen/widget/player_screen_widget.dart';
import 'package:media_player/service/preload_slides_service.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PlayerViewModel(
        getCurrentTrackUseCase: GetIt.I<GetCurrentTrackUseCase>(),  preloadSlidesService: GetIt.I<PreloadSlidesService>(),
      ),
      child: Builder(
        builder: (context) {
          final viewModel = context.read<PlayerViewModel>();
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(value: viewModel.getTrackBloc),
            ],
            child: PlayerScreenWidget(
            ),
          );
        },
      ),
    );
  }
}