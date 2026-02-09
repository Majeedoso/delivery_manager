import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_manager/core/services/logging_service.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_event.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_state.dart';

class CountdownBloc extends Bloc<CountdownEvent, CountdownState> {
  final LoggingService? _logger;
  Timer? _countdownTimer;

  CountdownBloc({
    LoggingService? logger,
  })  : _logger = logger,
        super(const CountdownState()) {
    on<StartCountdownEvent>(_onStartCountdown);
    on<StopCountdownEvent>(_onStopCountdown);
    on<TickCountdownEvent>(_onTickCountdown);
    on<CountdownCompletedEvent>(_onCountdownCompleted);
  }

  LoggingService get logger {
    try {
      return _logger ?? sl<LoggingService>();
    } catch (e) {
      return LoggingService();
    }
  }

  Future<void> _onStartCountdown(
    StartCountdownEvent event,
    Emitter<CountdownState> emit,
  ) async {
    logger.debug('CountdownBloc: Starting countdown for ${event.seconds} seconds');
    
    // Cancel any existing timer
    _countdownTimer?.cancel();
    
    // Emit initial state
    emit(state.copyWith(
      countdownSeconds: event.seconds,
      isActive: true,
    ));
    
    // Start periodic timer
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentSeconds = state.countdownSeconds;
      
      if (currentSeconds > 0) {
        add(const TickCountdownEvent());
      } else {
        timer.cancel();
        add(const CountdownCompletedEvent());
      }
    });
  }

  Future<void> _onStopCountdown(
    StopCountdownEvent event,
    Emitter<CountdownState> emit,
  ) async {
    logger.debug('CountdownBloc: Stopping countdown');
    _countdownTimer?.cancel();
    emit(const CountdownState());
  }

  Future<void> _onTickCountdown(
    TickCountdownEvent event,
    Emitter<CountdownState> emit,
  ) async {
    final newSeconds = state.countdownSeconds - 1;
    emit(state.copyWith(
      countdownSeconds: newSeconds,
      isActive: newSeconds > 0,
    ));
  }

  Future<void> _onCountdownCompleted(
    CountdownCompletedEvent event,
    Emitter<CountdownState> emit,
  ) async {
    logger.debug('CountdownBloc: Countdown completed');
    emit(state.copyWith(isActive: false));
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    return super.close();
  }
}

