import 'package:delivery_manager/features/countdown/presentation/controller/countdown_bloc.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_event.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_state.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/locator.dart';

/// The "resend the code in 42s" countdown shared by the code screens: one
/// second at a time down to zero, stoppable, restartable.
void main() {
  CountdownBloc build() => CountdownBloc(logger: silentLogger());

  test('counts down one second at a time, then ends', () {
    fakeAsync((async) {
      final bloc = build();

      bloc.add(const StartCountdownEvent(3));
      async.flushMicrotasks();
      expect(
        bloc.state,
        const CountdownState(countdownSeconds: 3, isActive: true),
      );

      async.elapse(const Duration(seconds: 1));
      expect(
        bloc.state,
        const CountdownState(countdownSeconds: 2, isActive: true),
      );

      async.elapse(const Duration(seconds: 2));
      expect(
        bloc.state,
        const CountdownState(countdownSeconds: 0, isActive: false),
      );

      async.elapse(const Duration(seconds: 5));
      expect(bloc.state.countdownSeconds, 0, reason: 'never below zero');
      expect(async.periodicTimerCount, 0, reason: 'the timer is gone');
      bloc.close();
    });
  });

  test('a stop resets it', () {
    fakeAsync((async) {
      final bloc = build();
      bloc.add(const StartCountdownEvent(120));
      async.elapse(const Duration(seconds: 10));

      bloc.add(const StopCountdownEvent());
      async.flushMicrotasks();

      expect(bloc.state, const CountdownState());
      expect(async.periodicTimerCount, 0);
      bloc.close();
    });
  });

  test('a new start replaces the running one', () {
    fakeAsync((async) {
      final bloc = build();
      bloc.add(const StartCountdownEvent(120));
      async.elapse(const Duration(seconds: 10));

      bloc.add(const StartCountdownEvent(60));
      async.elapse(const Duration(seconds: 1));

      expect(bloc.state.countdownSeconds, 59, reason: 'one timer, not two');
      expect(async.periodicTimerCount, 1);
      bloc.close();
    });
  });

  test('closing stops the timer', () {
    fakeAsync((async) {
      final bloc = build();
      bloc.add(const StartCountdownEvent(120));
      async.flushMicrotasks();

      bloc.close();
      async.flushMicrotasks();

      expect(async.periodicTimerCount, 0);
    });
  });
}
