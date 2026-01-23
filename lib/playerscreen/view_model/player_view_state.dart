import 'package:equatable/equatable.dart';
import 'package:media_player/getrecenttrackbloc/get_recent_track_state.dart';

class PlayerViewState extends Equatable {
  final int updateTrigger;
  final GetRecentTrackState? trackState;

  const PlayerViewState({
    this.updateTrigger = 0,
    this.trackState,
  });

  PlayerViewState copyWith({
    int? updateTrigger,
    GetRecentTrackState? trackState,
  }) {
    return PlayerViewState(
      updateTrigger: updateTrigger ?? this.updateTrigger,
      trackState: trackState ?? this.trackState,
    );
  }

  @override
  List<Object?> get props => [
    updateTrigger,
    trackState,
  ];
}