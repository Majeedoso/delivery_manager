import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class GetProfileEvent extends ProfileEvent {
  const GetProfileEvent();
}

class UpdateProfileEvent extends ProfileEvent {
  final String? name;
  final String? phone;

  const UpdateProfileEvent({
    this.name,
    this.phone,
  });

  @override
  List<Object?> get props => [name, phone];
}

class ChangePasswordEvent extends ProfileEvent {
  final String currentPassword;
  final String newPassword;
  final String newPasswordConfirmation;

  const ChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
    required this.newPasswordConfirmation,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword, newPasswordConfirmation];
}

class ChangeEmailEvent extends ProfileEvent {
  final String newEmail;
  final String currentPassword;

  const ChangeEmailEvent({
    required this.newEmail,
    required this.currentPassword,
  });

  @override
  List<Object?> get props => [newEmail, currentPassword];
}

class ConfirmEmailChangeEvent extends ProfileEvent {
  final String newEmail;
  final String otp;

  const ConfirmEmailChangeEvent({
    required this.newEmail,
    required this.otp,
  });

  @override
  List<Object?> get props => [newEmail, otp];
}

class SendDeleteAccountOtpEvent extends ProfileEvent {
  const SendDeleteAccountOtpEvent();
}

class VerifyDeleteAccountOtpEvent extends ProfileEvent {
  final String otp;

  const VerifyDeleteAccountOtpEvent({
    required this.otp,
  });

  @override
  List<Object?> get props => [otp];
}
