import 'package:flutter/material.dart';

/// Global navigator key used outside of BuildContext.
/// Imported by ApiService to redirect to login on 401 Unauthorized.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
