import 'package:media_player/model/playing_track_model.dart';

sealed class TrackStatus {
  const TrackStatus();
}

class TrackPlaying extends TrackStatus {
  final PlayingMediaModel? track;
  const TrackPlaying(this.track);
}

class TrackOutOfSchedule extends TrackStatus {
  const TrackOutOfSchedule();
}

class TrackNotFound extends TrackStatus {
  const TrackNotFound();
}

class TrackError extends TrackStatus {
  final Object error;
  const TrackError(this.error);
}

