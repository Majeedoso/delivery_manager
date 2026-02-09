import 'package:equatable/equatable.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/profile/domain/entities/profile.dart';

class ProfileState extends Equatable {
  final Profile? profile;
  final RequestState requestState;
  final String message;
  final int? resendCountdown;

  const ProfileState({
    this.profile,
    this.requestState = RequestState.loaded,
    this.message = '',
    this.resendCountdown,
  });

  ProfileState copyWith({
    Profile? profile,
    RequestState? requestState,
    String? message,
    int? resendCountdown,
    bool clearMessage = false,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      requestState: requestState ?? this.requestState,
      message: clearMessage ? '' : (message ?? this.message),
      resendCountdown: resendCountdown ?? this.resendCountdown,
    );
  }

  @override
  List<Object?> get props => [profile, requestState, message, resendCountdown];
}
