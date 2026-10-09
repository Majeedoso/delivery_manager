# delivery_manager tests

The same house style as `delivery_customer/test`, `delivery_driver/test`,
`delivery_restaurant/test` and `delivery_operator/test` (themselves after
`siba7a/swimboss_standalone`): every layer is tested, including repository
implementations, use cases, startup and dependency injection, and code that
depends on time.

## Running

```bash
cp .env.example .env        # first time only: .env is a required asset
flutter pub get
flutter analyze              # no issues in test/
flutter test                 # everything, about 2 and a half minutes
flutter test test/features/bank   # one folder
flutter test --coverage      # writes coverage/lcov.info
```

Nothing here calls the real backend, Firebase or a device plugin. The check
that does, against a throwaway copy of the backend, is in `test_live/`.

## Where things go

Tests mirror `lib/` and end in `_test.dart`
(`lib/features/users/presentation/controller/users_bloc.dart` →
`test/features/users/presentation/controller/users_bloc_test.dart`). A
feature's data layer (models, remote data source, repository) usually shares
one `data/<feature>_data_test.dart`. The statistics pages, which ask the
server themselves, have one file per family: `statistics_money_test.dart`,
`_orders_`, `_performance_`, `_ratings_` and `_hubs_`.

| Layer | How it is tested |
|---|---|
| Remote data sources | A real `Dio` whose transport is a scripted `FakeBackend`: check the request sent, the parsing, and the error mapping. Never mocked. |
| Local data sources | Real classes on the plugins' in-memory mocks (`SharedPreferences`, `FlutterSecureStorage`). |
| Repositories | Mocked remote data sources, real local storage: the `Right` values and the exception → `Failure` table, plus the repository's own logic. |
| Use cases | Mocked repositories; one `usecases_test.dart` per feature (or inside the feature's data test). |
| Blocs | `blocTest` with mocked use cases; a happy-path stub in `setUp`, overridden per test. |
| Screens and widgets | `MockBloc` + `whenListen` + `pumpPage`; blocs, use cases and services the screen looks up go into `sl` with the locator helpers. |
| Statistics pages | No bloc: the page asks `sl<Dio>()`. Register `testDio(backend)` with `registerService<Dio>` and script each path the page asks for. |
| Startup and DI | `startApp` with fake `StartupSteps`; the real `ServicesLocator().init()`; every route built through the real table (`test/core/routes/route_screens_test.dart`), and every argument a route can be given (`route_generator_test.dart`). |
| Notifications | `NotificationService` on fake plugins: the server sends a manager nothing, so the service only keeps the phone's token known to the server. The app creates no alert category, packs no sound and never asks for notifications (`test/core/services/notification_service_test.dart`, `test/app/android_manifest_test.dart`, `test/features/auth/presentation/controller/splash_bloc_test.dart`). |

## Helpers (`test/helpers/`)

- **`flutter_test_config.dart`** (in `test/`) runs around every file: phone
  fonts, date data, a test `.env`, fresh platform fakes before each test, a
  clean `sl` (with a silent logger and fake manager settings) after each test.
- **`platform.dart`**: `permissions`, `urlLauncher` (set `error` for a link
  the phone refuses), `clipboard`, `online` / `offline` DNS for
  `ConnectivityService.lookup`, `BrokenSecureStorage`, `loadTestEnv()`,
  `testBaseUrl`, `testHostUrl`, `packedSounds()`. All fakes are reinstalled
  before every test; change them in the test. The notification service's two
  doors to Firebase are closed by default: `NotificationService.fetchFcmToken`
  answers no token and `NotificationService.attachToFirebase` does nothing.
- **`fake_backend.dart`**: `FakeBackend` (`reply`, `replyInTurn`, `fail`,
  `hang`, `last`, `count`, `requests`) and `testDio(backend)`. An unscripted
  request fails the test.
- **`api_json.dart`**: Laravel-shaped bodies (`ok`, `failure`,
  `validationError`, `validationFailure`, `laravelPage`, `htmlErrorPage`) and
  the manager's payloads copied from the controllers that answer them
  (`ManagerController`, `UserManagementController`, `CouponController`,
  `SettingsController`, `CashReconciliationController`): the account, the
  users, the coupons and their zones, the settings, the bank's amounts and
  payments, the restaurants, the drivers and every statistics page.
- **`fixtures.dart`**: `testNow` (Wednesday 30 September 2026, noon),
  `localTime(serverTime)`, the order statuses the backend knows.
- **`fakes.dart`**: one mocktail mock per bloc, use case, repository and data
  source, plus `registerFallbacks()`.
- **`locator.dart`**: `registerBloc`, `registerUseCase`, `registerService`, and
  `publicSettings`: the manager's settings as the server gives them (the wait
  before another emailed code). A fake is always registered; change
  `publicSettings.values` to play another server.
- **`pump.dart`**: `pumpPage` (the app shell: Sizer, theme, l10n, app-level
  `blocs`, a 360×780 phone; `themeMode: ThemeMode.dark` for dark mode),
  `pumpInPage`, `pumpOpener` (dialogs and sheets), `scrollTo`, `flushAsync`.
  The app-level blocs main.dart provides are Localization, Theme, Auth and
  Countdown.
- **`readable.dart`**: `expectReadable(tester)` fails when a text on screen
  is too close in colour to what is painted behind it (dark mode found white
  sheets, black titles on black, white labels on fixed white cards).
- **`routes.dart`**: `RouteLog` (where the screen navigated, with which
  arguments), `stubRoute` (named routes render as "route: /name") and
  `appRoute` (the real route table).
- **`usecases.dart`**: `expectPassThrough`, for use cases that forward to
  their repository.

## House rules

- Test names are lowercase sentences about behaviour: "a refused decision is
  said, and the list stays". No "should", no Arrange/Act/Assert markers.
- Groups are noun phrases. Each file starts with a `///` comment saying why it
  exists.
- Put the business rule in `reason:` when an expectation isn't obvious.
- Register fakes in `setUp`, never `setUpAll`: `sl` is reset after each test.
- Create mocks fresh in `setUp`.
- Time: code reads `clock.now()`. Use `withClock(Clock.fixed(testNow), ...)`
  for dates and `fakeAsync` (or `tester.pump(duration)`) for timers and
  timeouts. Never sleep.
- Pass `settle: false` to `pumpPage` when the page animates forever.
- Each screen gets a French and an Arabic pump that must not overflow, and a
  dark-mode pump that must be readable (`expectReadable`).
- A tap or a drag that lands off the screen, or on another widget, fails
  the test (`flutter_test_config.dart`). Scroll to the target first
  (`scrollTo`), let a message that covers it leave, and tap the widget
  that takes the touch (a chip, not its text).
- The week begins on Sunday (`lib/core/utils/week.dart`), and so does every
  calendar: `pumpPage` lists `WeekMaterialLocalizations` before Flutter's
  own, as `main.dart` does, so a date picker in a test begins on Sunday in
  French and in Arabic too.
- A period that has a name is the calendar one, here as in every app: the
  filter says "This Week", "This Month", "This Year"; pick one in a test by
  `en.thisWeek`. The last 7 days are a date range.
- A bug a test finds is fixed in the same change, and the test proves the fix.
- `flutter analyze` must stay clean for `test/`.

## Gotchas

- **The bank's spinner is a Lottie animation** (also on the account status
  and profile pages): it never settles. Pump by hand (twice is usually
  enough) instead of `pumpAndSettle`.
- **The statistics pages ask the server themselves**, from `initState` and
  at each filter: script every path before pumping (a page with a list asks
  for the restaurants or the drivers too), and expect the query of the
  period chosen (`backend.last('GET', path).query`). Their lists read the
  server's `pagination` (ten a page) and ask for the next page at the
  bottom.
- **The bank names its sides**: a restaurant by its own id
  (`restaurant_id`), a driver by their user id; an amount the platform owes is
  a credit of the other side. The details page finds its amount by type, id
  and side, so a fixture must give all three.
- **`UsersState` has no `==`**: match it with `isA<UsersState>().having(...)`.
  `CouponsState`, `DashboardState` and the bank's states are Equatable.
- **A dialog over the page**: a text can be on the page, in the dialog's
  title and on its button at once. Look inside the dialog
  (`find.descendant(of: find.byType(AlertDialog), ...)`), or take the button
  with `find.ancestor(of: find.text(label), matching:
  find.bySubtype<ButtonStyleButton>()).last`.
- **A day picker**: tap the day's number, then "OK"; inside
  `withClock(Clock.fixed(testNow), ...)` the pickers end on 30 September 2026.
- **mocktail and named arguments**: a stub or `verify` naming some arguments
  matches only calls whose other named arguments are null. To check the
  arguments of a call, record them inside the stub (`thenAnswer((call) { ...
  })`); `captureAny` lists named arguments in another order.
- **mocktail and `dynamic`**: `verify(() => (bloc as dynamic).add(captureAny()))`
  passes `null` to a typed `add`, the call is never recorded, and the test
  reads "Used on a non-mocktail object". Keep the bloc's type
  (`captureAny<E>()`).
- **mocktail and `thenThrow`** on a method that is not `async`: the error is
  thrown before a `Future` exists. Use `thenAnswer((_) async => throw ...)`.
- **Buttons**: a Material 3 `IconButton` is a `ButtonStyleButton`, and
  `find.byType(ElevatedButton)` misses `ElevatedButton.icon`: use
  `find.bySubtype<ElevatedButton>()`. A button that waits shows a spinner
  instead of its label: find it by type.
- **A text can show twice** (on the page and in a snackbar): `findsWidgets`.
- **`.w` and `.h` outside the Sizer builder throw**.
- **Going back**: `tester.pageBack()` needs the default back button; tap the
  page's own arrow, or use `tester.binding.handlePopRoute()` for the phone's
  back button. `stubRoute` pages have none: `navigatorKey.currentState!.pop()`.
- **Pinput** (code fields): its cursor blinks forever once focused, so pump
  by hand after typing; setting its controller's text fires `onCompleted`.
- **A page that can be left** (back button, `PopScope`, a result returned):
  push it with `pumpOpener` so there is a page below it; one test per dialog
  (a second `pumpOpener` finds the first dialog still open).
- **Equatable** compares runtime types: a model is never equal to its
  entity. Compare `.props`, or build the same type.
- **Overflows**: `takeException()` hides where; copy the test, collect
  `FlutterError.onError` details and print the lines with `dart:`.
- **New route**: add it to `test/core/routes/route_screens_test.dart`, which
  builds every route through the real table (it fails otherwise).
- **Translations**: `test/l10n/arb_files_test.dart` fails on a key written
  twice, a missing key, a text left in English (letters compared, so "•
  Notify you..." is still English), a file saved in the wrong encoding, a
  letter lost to "?", a driver called anything but "livreur" in French, and
  "Discard" written like "Cancel". A French text that is right with the
  English letters goes in `_sameInFrench`. Edit the `.arb` files as UTF-8,
  then `flutter gen-l10n`.
- **The platform settings** are named and explained by the app, in its
  language (`lib/features/dashboard/presentation/setting_texts.dart`): the
  server's English names are shown only for a key the app does not know.
- **Server times are UTC.** Models and pages read them with `parseServerTime`
  (`lib/core/utils/server_time.dart`); tests write the expected hour with
  `localTime(serverTime)` or `DateTime.utc(...).toLocal()`, so they pass in
  any time zone.
- **A week, a month and a year are the calendar ones** (`PeriodCalculator`:
  since Sunday, the 1st, 1 January), as the server counts the statistics.
- **A failed request** says the same thing in every data source
  (`lib/core/network/request_failure.dart`): the server's sentence (of a
  refused field, the sentence about it), `Request timeout` or `Network
  connection error`, which `ErrorMessageMapper` translates, or `Server error
  occurred`.
- **A bloc on a fixed clock**: build it inside `withClock`
  (`build: () => withClock(Clock.fixed(testNow), build)`); its handlers run in
  the zone it was built in, not the one the event was added from.
- **Answers that come back late**: give each call its own `Completer`, add the
  second event, complete the second answer first. The users list keeps only
  the last answer asked for.
- **`fakeAsync`**: create `Completer`s inside its callback. One made outside
  completes on the real event loop, and the test can pass for the wrong reason.
- **Snackbars**: the 4 seconds start once it has slid in. To see one go,
  `pump(1 s)`, then `pump(5 s)`, then `pumpAndSettle()`.
- **Line endings**: most files of `lib/` are CRLF. A shell `sed -i` rewrites
  them as LF; edit with the IDE or a script that keeps them.
- **Git Bash**: a test name starting with `/` needs `MSYS_NO_PATHCONV=1`
  before `flutter test --plain-name`.
