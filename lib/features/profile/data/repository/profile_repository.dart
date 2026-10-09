import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/features/profile/data/datasource/profile_remote_data_source.dart';
import 'package:delivery_manager/features/profile/domain/entities/profile.dart';
import 'package:delivery_manager/features/profile/domain/entities/resend_email_change_otp_response.dart';
import 'package:delivery_manager/features/profile/domain/entities/confirm_email_change_response.dart';
import 'package:delivery_manager/features/profile/domain/entities/send_delete_account_otp_response.dart';
import 'package:delivery_manager/features/profile/domain/repository/base_profile_repository.dart';

class ProfileRepository implements BaseProfileRepository {
  final BaseProfileRemoteDataSource baseProfileRemoteDataSource;

  ProfileRepository({
    required this.baseProfileRemoteDataSource,
  });

  @override
  Future<Either<Failure, Profile>> getProfile() async {
    try {
      final profile = await baseProfileRemoteDataSource.getProfile();
      return Right(profile);
    } on ServerException catch (failure) {
      return Left(ServerFailure(failure.message));
    } on ValidationException catch (failure) {
      return Left(ValidationFailure(failure.message));
    } on NetworkException catch (failure) {
      return Left(NetworkFailure(failure.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Profile>> updateProfile({
    String? name,
    String? phone,
  }) async {
    try {
      final profile = await baseProfileRemoteDataSource.updateProfile(
        name: name,
        phone: phone,
      );
      return Right(profile);
    } on ServerException catch (failure) {
      return Left(ServerFailure(failure.message));
    } on ValidationException catch (failure) {
      return Left(ValidationFailure(failure.message));
    } on NetworkException catch (failure) {
      return Left(NetworkFailure(failure.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      await baseProfileRemoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );
      return const Right(null);
    } on ServerException catch (failure) {
      return Left(ServerFailure(failure.message));
    } on ValidationException catch (failure) {
      return Left(ValidationFailure(failure.message));
    } on NetworkException catch (failure) {
      return Left(NetworkFailure(failure.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, ResendEmailChangeOtpResponse>> changeEmail({
    required String newEmail,
    required String currentPassword,
  }) async {
    try {
      final response = await baseProfileRemoteDataSource.changeEmail(
        newEmail: newEmail,
        currentPassword: currentPassword,
      );
      return Right(response);
    } on ServerException catch (failure) {
      return Left(ServerFailure(failure.message));
    } on ValidationException catch (failure) {
      return Left(ValidationFailure(failure.message));
    } on NetworkException catch (failure) {
      return Left(NetworkFailure(failure.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, ConfirmEmailChangeResponse>> confirmEmailChange({
    required String newEmail,
    required String otp,
  }) async {
    try {
      final response = await baseProfileRemoteDataSource.confirmEmailChange(
        newEmail: newEmail,
        otp: otp,
      );
      return Right(response);
    } on ServerException catch (failure) {
      return Left(ServerFailure(failure.message));
    } on ValidationException catch (failure) {
      return Left(ValidationFailure(failure.message));
    } on NetworkException catch (failure) {
      return Left(NetworkFailure(failure.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, SendDeleteAccountOtpResponse>> sendDeleteAccountOtp() async {
    try {
      final response = await baseProfileRemoteDataSource.sendDeleteAccountOtp();
      return Right(response);
    } on ServerException catch (failure) {
      return Left(ServerFailure(failure.message));
    } on NetworkException catch (failure) {
      return Left(NetworkFailure(failure.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> verifyDeleteAccountOtpAndDelete({
    required String otp,
  }) async {
    try {
      await baseProfileRemoteDataSource.verifyDeleteAccountOtpAndDelete(otp: otp);
      return const Right(null);
    } on ServerException catch (failure) {
      return Left(ServerFailure(failure.message));
    } on ValidationException catch (failure) {
      return Left(ValidationFailure(failure.message));
    } on NetworkException catch (failure) {
      return Left(NetworkFailure(failure.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
