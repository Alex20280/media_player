import 'package:equatable/equatable.dart';

class PlayerViewState extends Equatable {
  final int updateTrigger;

  const PlayerViewState({this.updateTrigger = 0});

  PlayerViewState copyWith({int? updateTrigger}) {
    return PlayerViewState(
      updateTrigger: updateTrigger ?? this.updateTrigger,
    );
  }

  @override
  List<Object?> get props => [updateTrigger];
}