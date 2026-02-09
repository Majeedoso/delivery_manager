import 'package:equatable/equatable.dart';

/// Base class for all app version-related events
/// 
/// This abstract class extends Equatable to enable state comparison
/// and is used as the event type for the AppVersionBloc.
abstract class AppVersionEvent extends Equatable {
  const AppVersionEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when app needs to check version compatibility
class CheckAppVersionEvent extends AppVersionEvent {
  const CheckAppVersionEvent();
}

