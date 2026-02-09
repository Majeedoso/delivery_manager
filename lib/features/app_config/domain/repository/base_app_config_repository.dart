import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/features/app_config/domain/entities/legal_urls.dart';
import 'package:delivery_manager/features/app_config/domain/entities/contact_info.dart';

/// Base repository interface for app configuration
/// 
/// This repository handles fetching app configuration data from remote sources.
/// Following Clean Architecture, this is an abstract interface that will be
/// implemented by the data layer.
abstract class BaseAppConfigRepository {
  /// Get legal document URLs (privacy policy and terms of service)
  /// 
  /// [languageCode] - Optional language code (ar, en, fr) to get URLs in specific language.
  /// Returns Either<Failure, LegalUrls>:
  /// - Right(LegalUrls): Successfully retrieved URLs
  /// - Left(Failure): Error occurred during retrieval
  Future<Either<Failure, LegalUrls>> getLegalUrls({String? languageCode});

  /// Get contact information (email, phone, website)
  /// 
  /// Returns Either<Failure, ContactInfo>:
  /// - Right(ContactInfo): Successfully retrieved contact information
  /// - Left(Failure): Error occurred during retrieval
  Future<Either<Failure, ContactInfo>> getContactInfo();
}

