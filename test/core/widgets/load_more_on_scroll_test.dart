import 'package:delivery_manager/core/widgets/load_more_on_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump.dart';

/// Every list loads its next page as it nears its end, and at once when a
/// page is too short to scroll (the owner's rule, 2026-11-15: 10 at a time,
/// no "Load more" button).
void main() {
  late int asked;

  /// The list as its page shows it: what the next state brings changes it
  /// in place, as a bloc's would.
  late ValueNotifier<(int, bool, bool)> shown;

  setUp(() {
    asked = 0;
    shown = ValueNotifier((3, true, false));
  });

  Widget list() => ValueListenableBuilder<(int, bool, bool)>(
    valueListenable: shown,
    builder: (_, value, _) {
      final (rows, hasMore, loading) = value;
      return LoadMoreOnScroll(
        hasMore: hasMore,
        isLoadingMore: loading,
        itemCount: rows,
        onLoadMore: () => asked++,
        child: ListView.builder(
          itemCount: rows,
          itemBuilder: (_, i) => SizedBox(height: 80, child: Text('Row $i')),
        ),
      );
    },
  );

  Future<void> change(WidgetTester tester, (int, bool, bool) value) async {
    shown.value = value;
    await tester.pumpAndSettle();
  }

  testWidgets('a page too short to scroll asks for the next, once', (
    tester,
  ) async {
    await pumpInPage(tester, list());
    await change(tester, (3, true, false));
    await tester.pump(const Duration(seconds: 1));

    expect(asked, 1);
  });

  testWidgets('a page that came and is still short asks again', (
    tester,
  ) async {
    await pumpInPage(tester, list());
    await change(tester, (3, true, true));
    await change(tester, (5, true, false));

    expect(asked, 2);
  });

  // A short list keeps the same scroll metrics when its state changes:
  // nothing was asked once a next page appeared
  testWidgets('a short list asks once a next page appears', (tester) async {
    shown.value = (3, false, false);
    await pumpInPage(tester, list());
    expect(asked, 0);

    await change(tester, (3, true, false));

    expect(asked, 1);
  });

  testWidgets('a long page asks only near its end', (tester) async {
    shown.value = (50, true, false);
    await pumpInPage(tester, list());
    expect(asked, 0);

    await tester.drag(find.byType(ListView), const Offset(0, -5000));
    await tester.pumpAndSettle();

    expect(asked, 1, reason: 'one ask, not one for each frame of the scroll');
  });

  // Asked a screen ahead, the next rows are there when the list ends
  testWidgets('a long page asks once less than a screen of rows is left', (
    tester,
  ) async {
    shown.value = (50, true, false);
    await pumpInPage(tester, list());
    final position = tester
        .state<ScrollableState>(
          find.descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          ),
        )
        .position;

    position.jumpTo(
      position.maxScrollExtent - position.viewportDimension - 100,
    );
    await tester.pump();
    expect(asked, 0);

    position.jumpTo(
      position.maxScrollExtent - position.viewportDimension + 100,
    );
    await tester.pump();
    expect(asked, 1);
  });

  testWidgets('a page that failed: the next scroll asks again', (
    tester,
  ) async {
    shown.value = (50, true, false);
    await pumpInPage(tester, list());
    await tester.drag(find.byType(ListView), const Offset(0, -5000));
    await tester.pumpAndSettle();

    await change(tester, (50, true, true));
    await change(tester, (50, true, false));
    expect(asked, 1, reason: 'not by itself: it would ask in a loop');

    await tester.drag(find.byType(ListView), const Offset(0, 200));
    await tester.pumpAndSettle();

    expect(asked, 2);
  });

  testWidgets('nothing asked while a page is on its way, nor when none is '
      'left', (tester) async {
    shown.value = (3, true, true);
    await pumpInPage(tester, list());
    await change(tester, (3, false, false));

    expect(asked, 0);
  });
}
