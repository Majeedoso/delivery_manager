import 'dart:async';
import 'dart:io';
import 'package:delivery_manager/core/services/logging_service.dart';
import 'package:delivery_manager/core/services/services_locator.dart';

/// Service to check internet connectivity
/// Uses HTTP lookup to verify actual internet access
class ConnectivityService {
  /// Get logging service instance
  static LoggingService get _logger {
    try {
      return sl<LoggingService>();
    } catch (e) {
      // Fallback to a simple logger if service locator not ready
      return LoggingService();
    }
  }
  
  /// Check if device has internet connectivity
  /// Returns true if device has active internet connection
  /// Returns false if no internet connection is available
  /// 
  /// Uses HTTP lookup to verify actual internet access by checking 5 different hosts
  /// This is a Future-based approach that's more reliable than Stream-based checks
  /// Only returns false if ALL 5 hosts fail to respond
  static Future<bool> hasInternetConnection() async {
    try {
      // Give the network interface a moment to initialize on app startup
      await Future.delayed(const Duration(milliseconds: 200));
      
      // List of 5 reliable hosts to check for internet connectivity
      final List<String> hosts = [
        'google.com',
        'cloudflare.com',
        'microsoft.com',
        'amazon.com',
        'github.com',
      ];
      
      // Try up to 2 times with timeout for reliable detection
      for (int attempt = 0; attempt < 2; attempt++) {
        int failedHosts = 0;
        
        // Check all 5 hosts
        for (String host in hosts) {
          try {
            // Use HTTP lookup to check internet connectivity
            // This is a Future-based approach that's more reliable
            final result = await InternetAddress.lookup(host)
                .timeout(
                  const Duration(seconds: 10),
                  onTimeout: () {
                    _logger.warning('ConnectivityService: DNS lookup for $host timed out after 10 seconds (attempt ${attempt + 1})');
                    throw TimeoutException('DNS lookup timeout');
                  },
                );
            
            final hasInternet = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
            
            if (hasInternet) {
              _logger.info('ConnectivityService: Internet connection confirmed via $host (attempt ${attempt + 1})');
              return true;
            }
            
            _logger.debug('ConnectivityService: $host lookup failed (attempt ${attempt + 1})');
            failedHosts++;
          } on SocketException catch (e) {
            _logger.debug('ConnectivityService: $host lookup failed (attempt ${attempt + 1}): ${e.message}');
            failedHosts++;
          } on TimeoutException {
            _logger.warning('ConnectivityService: $host lookup timed out (attempt ${attempt + 1})');
            failedHosts++;
          } catch (e) {
            _logger.error('ConnectivityService: Error checking $host (attempt ${attempt + 1})', error: e);
            failedHosts++;
          }
        }
        
        // If all 5 hosts failed, check if we should retry
        if (failedHosts == hosts.length) {
          _logger.debug('ConnectivityService: All ${hosts.length} hosts failed (attempt ${attempt + 1})');
          
          // If first attempt failed, wait a bit and retry
          if (attempt == 0) {
            await Future.delayed(const Duration(milliseconds: 500));
            continue;
          }
          
          // All hosts failed after retries
          _logger.warning('ConnectivityService: No internet connection - all ${hosts.length} hosts failed after retries');
          return false;
        }
      }
      
      _logger.warning('ConnectivityService: No internet connection after retries');
      return false;
    } catch (e) {
      // On any outer error, assume no connection (be strict)
      _logger.error('ConnectivityService: Error checking connectivity', error: e);
      return false;
    }
  }
}

