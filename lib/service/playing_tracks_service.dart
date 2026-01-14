import 'dart:async';

typedef VoidCallback = void Function();

class PlayingTracksService {
  Timer? _timer;

  void startSingleTimer(Duration targetDuration, VoidCallback onTimerComplete) {
    _timer?.cancel();

    _timer = Timer(targetDuration, () {
      onTimerComplete();
    });
  }

  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void timerDispose() {
    cancelTimer();
  }
}