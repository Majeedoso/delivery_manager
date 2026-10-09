import 'package:dio/dio.dart';
import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/core/network/api_constance.dart';
import 'package:delivery_manager/features/app_config/data/models/legal_urls_model.dart';
import 'package:delivery_manager/features/app_config/data/models/contact_info_model.dart';

/// Abstract interface for app configuration remote data source
/// 
/// This defines the contract for fetching app configuration data from the API.
abstract class BaseAppConfigRemoteDataSource {
  /// Get legal document URLs from the API
  /// 
  /// [languageCode] - Optional language code (ar, en, fr) to get URLs in specific language.
  /// Returns LegalUrlsModel containing privacy policy and terms of service URLs.
  /// Throws ServerException if the API call fails.
  Future<LegalUrlsModel> getLegalUrls({String? languageCode});

  /// Get contact information from the API
  /// 
  /// Returns ContactInfoModel containing email, phone, and website.
  /// Throws ServerException if the API call fails.
  Future<ContactInfoModel> getContactInfo();
}

/// Implementation of app configuration remote data source
/// 
/// This class handles API calls to fetch app configuration data.
class AppConfigRemoteDataSourceImpl implements BaseAppConfigRemoteDataSource {
  /// The app's shared Dio (base URL, language, token, retries). A separate
  /// ApiService used to turn every DioException into a plain Exception, so
  /// being offline was reported as "An unexpected error occurred".
  final Dio dio;

  AppConfigRemoteDataSourceImpl({required this.dio});

  static String? _messageOf(Object? body) =>
      body is Map && body['message'] is String ? body['message'] as String : null;

  @override
  Future<LegalUrlsModel> getLegalUrls({String? languageCode}) async {
    try {
      final queryParameters = languageCode != null 
          ? {'lang': languageCode}
          : null;
      
      final response = await dio.get(
        ApiConstance.legalUrlsPath,
        queryParameters: queryParameters,
      );

      if (response.data['success'] == true) {
        return LegalUrlsModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to get legal URLs',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw NetworkException(
          message: 'Network error. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.badResponse) {
        throw ServerException(
          message: _messageOf(e.response?.data) ?? 'Server error occurred',
        );
      } else {
        throw ServerException(
          message: e.message ?? 'Failed to get legal URLs',
        );
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  @override
  Future<ContactInfoModel> getContactInfo() async {
    try {
      final response = await dio.get(
        ApiConstance.contactInfoPath,
      );

      if (response.data['success'] == true) {
        return ContactInfoModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to get contact information',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw NetworkException(
          message: 'Network error. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.badResponse) {
        throw ServerException(
          message: _messageOf(e.response?.data) ?? 'Server error occurred',
        );
      } else {
        throw ServerException(
          message: e.message ?? 'Failed to get contact information',
        );
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }
}

