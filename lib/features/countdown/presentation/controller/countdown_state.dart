import 'package:equatable/equatable.dart';

class CountdownState extends Equatable {
  final int countdownSeconds;
  final bool isActive;

  const CountdownState({
    this.countdownSeconds = 0,
    this.isActive = false,
  });

  CountdownState copyWith({
    int? countdownSeconds,
    bool? isActive,
  }) {
    return CountdownState(
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        countdownSeconds,
        isActive,
      ];
}

