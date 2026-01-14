import 'dart:async';

abstract class GetRecentTrackEvent {}

class LoadLocalTrackEvent extends GetRecentTrackEvent {
  final Completer? completer;

  LoadLocalTrackEvent([this.completer]);
}