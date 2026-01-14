import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_player/playerscreen/view_model/player_view_model.dart';
import 'package:media_player/root_screen.dart';
import 'package:media_player/service/playing_tracks_service.dart';
import 'package:media_player/service/preload_slides_service.dart';
import 'package:media_player/service/video_player_manager_service.dart';
import 'package:media_player/use_case/get_current_track_use_case.dart';
import 'package:media_player/welcomescreen/welcom_screen.dart';
import 'package:talker_bloc_logger/talker_bloc_logger.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:talker_flutter/talker_flutter.dart' hide LogLevel;
import 'package:get_it/get_it.dart';

void main() async {
  runZonedGuarded(
        () async {
      WidgetsFlutterBinding.ensureInitialized();
      MediaKit.ensureInitialized();

      final talker = TalkerFlutter.init();
      GetIt.I.registerSingleton(talker);


      Bloc.observer = TalkerBlocObserver(
        settings: TalkerBlocLoggerSettings(
          enabled: true,
          printEventFullData: false,
          printStateFullData: false,
          printChanges: true,
          printClosings: true,
          printCreations: true,
          printEvents: true,
          printTransitions: true,
          transitionFilter: (bloc, transition) => bloc.runtimeType.toString() == 'AuthBloc',
          eventFilter: (bloc, event) => bloc.runtimeType.toString() == 'AuthBloc',
        ),
      );

      _registerServices();
      _registerUseCases();
      _registerViewModels();

      GetIt.I.registerLazySingleton<Completer>(() => Completer());
      runApp(
        MaterialApp(
          home: RootScreen(),
        ),
      );
    },
        (e, st) {
      GetIt.I<Talker>().handle(e, st);
    },
  );
}


void _registerViewModels() {

  GetIt.I.registerFactory<PlayerViewModel>(
        () => PlayerViewModel(
      getCurrentTrackUseCase: GetIt.I<GetCurrentTrackUseCase>(),
      preloadSlidesService: GetIt.I<PreloadSlidesService>(),
    ),
  );
}

void _registerServices() {
  GetIt.I.registerLazySingleton<PlayingTracksService>(
        () => PlayingTracksService(),
  );

  GetIt.I.registerLazySingleton<ScheduleTrackPlayerService>(
        () => ScheduleTrackPlayerService(),
  );

  GetIt.I.registerLazySingleton<PreloadSlidesService>(
        () => PreloadSlidesService(),
  );

}

void _registerUseCases() {


  GetIt.I.registerLazySingleton<GetCurrentTrackUseCase>(
        () => GetCurrentTrackUseCase(
      GetIt.I<PlayingTracksService>(),
    ),
  );

}
