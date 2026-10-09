import 'package:delivery_manager/core/theme/theme.dart';
import 'package:delivery_manager/core/utils/app_navigator.dart';
import 'package:delivery_manager/core/utils/week_material_localizations.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';

import 'fonts.dart';
import 'routes.dart';

/// A phone held upright: the app locks portrait, and sizer's `.w`, `.h` and
/// `.sp` are computed from this size.
const phoneSize = Size(360, 780);

/// Pumps [page] inside the shell main.dart builds: Sizer (its `Device` fields
/// are `static late`, so any `.w` throws without it), then a MaterialApp with
/// the app's theme (drawn with a phone's fonts, see [withPhoneFonts]), l10n
/// and navigator key.
///
/// [blocs] are the app-level blocs main.dart provides above the MaterialApp
/// (Localization, Theme, Auth, Countdown), so pushed routes see them too.
/// Named routes the page pushes render as placeholders ([stubRoute]) unless
/// [onGenerateRoute] is given; pass a [RouteLog] to see where the page went.
///
/// Pass `settle: false` when the page animates forever (a progress indicator,
/// a Lottie loop): pumpAndSettle would time out. With [themeMode] dark, the
/// page is drawn with the app's dark theme, as on a phone set to dark mode.
Future<void> pumpPage(
  WidgetTester tester,
  Widget page, {
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
  bool settle = true,
  List<BlocProvider> blocs = const [],
  RouteLog? routes,
  RouteFactory? onGenerateRoute,
}) async {
  usePhoneScreen(tester);
  await tester.pumpWidget(
    testApp(
      home: page,
      locale: locale,
      themeMode: themeMode,
      blocs: blocs,
      routes: routes,
      onGenerateRoute: onGenerateRoute,
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

/// The widget [pumpPage] pumps, for tests that need to build it themselves.
Widget testApp({
  required Widget home,
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
  List<BlocProvider> blocs = const [],
  RouteLog? routes,
  RouteFactory? onGenerateRoute,
}) {
  final Widget app = Sizer(
    builder: (context, orientation, screenType) => MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: withPhoneFonts(MaterialTheme.lightTheme()),
      darkTheme: withPhoneFonts(MaterialTheme.darkTheme()),
      themeMode: themeMode,
      locale: locale,
      // As main.dart: a calendar's week begins on Sunday in every language
      localizationsDelegates: const [
        WeekMaterialLocalizations.delegate,
        ...AppLocalizations.localizationsDelegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      navigatorObservers: [?routes],
      onGenerateRoute: onGenerateRoute ?? stubRoute,
      home: home,
    ),
  );
  return blocs.isEmpty ? app : MultiBlocProvider(providers: blocs, child: app);
}

/// Pumps [widget] alone on a page, for widgets that aren't screens.
Future<void> pumpInPage(
  WidgetTester tester,
  Widget widget, {
  Locale locale = const Locale('en'),
  bool settle = true,
  List<BlocProvider> blocs = const [],
  RouteLog? routes,
}) => pumpPage(
  tester,
  Scaffold(body: widget),
  locale: locale,
  settle: settle,
  blocs: blocs,
  routes: routes,
);

/// Pumps a page with an "open" button that runs [open] (a dialog, a bottom
/// sheet, a pushed page), taps it, and returns what [open] will return.
Future<Future<T?>> pumpOpener<T>(
  WidgetTester tester,
  Future<T?> Function(BuildContext context) open, {
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
  bool settle = true,
  List<BlocProvider> blocs = const [],
  RouteLog? routes,
}) async {
  late Future<T?> result;
  await pumpPage(
    tester,
    Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () => result = open(context),
            child: const Text('open'),
          ),
        ),
      ),
    ),
    locale: locale,
    themeMode: themeMode,
    blocs: blocs,
    routes: routes,
  );
  await tester.tap(find.text('open'));
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
  return result;
}

/// Lets real file work finish (a picked photo is measured, rewritten and
/// measured again on the disk): a widget test's clock is fake, so each step
/// on the disk needs a moment of real time, then a frame. With [until], it
/// goes on (up to five seconds) until that is true: on a busy machine (the
/// whole suite at once) the rounds may end before the work does.
Future<void> settleFiles(
  WidgetTester tester, {
  int rounds = 30,
  bool Function()? until,
}) async {
  for (var i = 0; i < rounds || (until != null && !until() && i < 500); i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

/// Sets a 360×780 portrait screen for this test (and resets it afterwards).
void usePhoneScreen(WidgetTester tester, {Size size = phoneSize}) {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

/// Scrolls until [finder] is built and visible, for long forms and lists.
Future<void> scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

/// Drops "RenderFlex overflowed" reports for the rest of the test.
///
/// Only for tests that pump the app's own shell (MyApp), whose theme can't be
/// given phone fonts: the test engine draws its family-less button labels
/// with a square font about twice as wide as Roboto, so those overflows are
/// not real. Every screen's layout is checked with real fonts in its own test.
void ignoreOverflowFromTestFont() {
  final report = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exceptionAsString().contains('RenderFlex overflowed')) return;
    report?.call(details);
  };
  addTearDown(() => FlutterError.onError = report);
}

/// Lets queued microtasks and zero-length timers run: a stream listener, the
/// awaited use case and whatever it triggers.
Future<void> flushAsync() async {
  for (var i = 0; i < 10; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}
