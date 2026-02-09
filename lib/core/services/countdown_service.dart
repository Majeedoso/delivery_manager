import 'dart:async';

class CountdownService {
  static final CountdownService _instance = CountdownService._internal();
  factory CountdownService() => _instance;
  CountdownService._internal();

  Timer? _countdownTimer;
  int _countdownSeconds = 0;
  final StreamController<int> _countdownController = StreamController<int>.broadcast();

  // Stream to listen to countdown changes
  Stream<int> get countdownStream => _countdownController.stream;

  // Get current countdown seconds
  int get countdownSeconds => _countdownSeconds;

  // Check if countdown is active
  bool get isCountdownActive => _countdownSeconds > 0;

  // Start countdown timer
  void startCountdown(int seconds) {
    _countdownTimer?.cancel();
    _countdownSeconds = seconds;
    _countdownController.add(_countdownSeconds);
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _countdownSeconds--;
      _countdownController.add(_countdownSeconds);
      
      if (_countdownSeconds <= 0) {
        timer.cancel();
      }
    });
  }

  // Stop countdown timer
  void stopCountdown() {
    _countdownTimer?.cancel();
    _countdownSeconds = 0;
    _countdownController.add(_countdownSeconds);
  }

  // Dispose resources
  void dispose() {
    _countdownTimer?.cancel();
    _countdownController.close();
  }
}
