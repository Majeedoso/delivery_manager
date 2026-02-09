import 'package:equatable/equatable.dart';

abstract class CountdownEvent extends Equatable {
  const CountdownEvent();

  @override
  List<Object?> get props => [];
}

class StartCountdownEvent extends CountdownEvent {
  final int seconds;

  const StartCountdownEvent(this.seconds);

  @override
  List<Object?> get props => [seconds];
}

class StopCountdownEvent extends CountdownEvent {
  const StopCountdownEvent();
}

class TickCountdownEvent extends CountdownEvent {
  const TickCountdownEvent();
}

class CountdownCompletedEvent extends CountdownEvent {
  const CountdownCompletedEvent();
}

