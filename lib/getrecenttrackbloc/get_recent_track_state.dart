import 'package:media_kit/media_kit.dart';
import 'package:media_player/model/playing_track_model.dart';

abstract class GetRecentTrackState {}

class RecentTrackInitial extends GetRecentTrackState {}

class RecentTrackLoading extends GetRecentTrackState {}

class RecentTrackSuccess extends GetRecentTrackState {
  final PlayingMediaModel? currentTrack;

  RecentTrackSuccess({
    required this.currentTrack
  });

  RecentTrackSuccess copyWith({
    PlayingMediaModel? currentTrack,
    Player? controller
  }) {
    return RecentTrackSuccess(
        currentTrack: currentTrack ?? this.currentTrack
    );
  }
}

class RecentTrackError extends GetRecentTrackState {
  final String message;

  RecentTrackError(this.message);
}

class RecentTrackOutOfSchedule extends GetRecentTrackState {}
