import 'package:equatable/equatable.dart';
import 'package:delivery_manager/features/profile/domain/entities/profile.dart';

/// Response entity for email change confirmation
/// 
/// This entity represents the response from confirming email change with OTP.
/// 
/// Contains:
/// - [profile]: The updated profile with new email
/// - [message]: Success message
class ConfirmEmailChangeResponse extends Equatable {
  final Profile profile;
  final String message;

  const ConfirmEmailChangeResponse({
    required this.profile,
    required this.message,
  });

  @override
  List<Object> get props => [profile, message];
}

