import 'package:flutter/material.dart';

/// Global navigator key used outside of BuildContext.
/// Used to navigate from outside the widget tree (notifications, the
/// account-suspended redirect).
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
