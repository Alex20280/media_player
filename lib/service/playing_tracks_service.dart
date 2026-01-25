import 'dart:async';

typedef VoidCallback = void Function();

class PlayingTracksService {
  Timer? _timer;
  
  Stopwatch _stopwatch = Stopwatch();
  Duration? _targetDuration;
  VoidCallback? _onComplete;

  void startSingleTimer(Duration targetDuration, VoidCallback onTimerComplete) {
    cancelTimer();

    _targetDuration = targetDuration;
    _onComplete = onTimerComplete;
    _stopwatch.reset();
    _stopwatch.start();

    _timer = Timer(targetDuration, () {
      _finish();
    });
  }

  void pauseTimer() {
    if (_timer != null && _timer!.isActive) {
      _stopwatch.stop();
      _timer?.cancel();
    }
  }

  void resumeTimer() {
    if (_targetDuration != null && _onComplete != null && !_stopwatch.isRunning) {
      final elapsed = _stopwatch.elapsed;
      final remaining = _targetDuration! - elapsed;

      if (remaining > Duration.zero) {
        _stopwatch.start();
        _timer = Timer(remaining, () {
          _finish();
        });
      } else {
        _finish();
      }
    }
  }

  void _finish() {
    cancelTimer();
    _onComplete?.call();
  }

  void cancelTimer() {
    _timer?.cancel();
    _stopwatch.stop();
    _stopwatch.reset();
    _timer = null;
  }

  void timerDispose() {
    cancelTimer();
    _targetDuration = null;
    _onComplete = null;
  }
}