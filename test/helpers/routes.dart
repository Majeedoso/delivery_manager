import 'package:delivery_manager/core/routes/route_generator.dart';
import 'package:flutter/material.dart';

/// Opens a route through the table main.dart gives MaterialApp (`routes:`),
/// as the app does: the same builder in a MaterialPageRoute carrying the
/// arguments, and the app's "page not found" for a name it doesn't know.
/// Pass it as `onGenerateRoute` to build the real screens.
Route<dynamic> appRoute(RouteSettings settings) {
  final builder = RouteGenerator.generateRoutes()[settings.name];
  return builder == null
      ? RouteGenerator.unknownRoute(settings)
      : MaterialPageRoute<dynamic>(builder: builder, settings: settings);
}

/// Remembers every route pushed, replaced or popped, so a test can check where
/// a screen went and with which arguments.
class RouteLog extends NavigatorObserver {
  final pushed = <RouteSettings>[];
  final popped = <RouteSettings>[];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      pushed.add(route.settings);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) pushed.add(newRoute.settings);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      popped.add(route.settings);

  /// Names of the named routes pushed, oldest first (the home page is '/').
  List<String?> get names => [for (final route in pushed) route.name];

  RouteSettings get last => pushed.last;

  /// The arguments of the last route pushed, as a map.
  Map<String, dynamic> get lastArguments =>
      last.arguments as Map<String, dynamic>;
}

/// Builds every named route as a placeholder page reading "route: /name", so
/// navigating in a test doesn't build the real screen and its blocs.
Route<dynamic> stubRoute(RouteSettings settings) => MaterialPageRoute<dynamic>(
  settings: settings,
  builder: (_) => Scaffold(body: Text('route: ${settings.name}')),
);

/// Finds the placeholder page of [route] (see [stubRoute]).
String routeText(String route) => 'route: $route';
