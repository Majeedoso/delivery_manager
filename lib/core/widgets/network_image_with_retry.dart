import 'dart:typed_data';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:delivery_manager/core/utils/app_logger.dart';

/// A widget that loads network images with retry logic using Dart's HttpClient
/// Uses HTTP/1.0 to avoid Keep-Alive connection issues with Apache/XAMPP
class NetworkImageWithRetry extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;
  final Widget Function(BuildContext, Widget, ImageChunkEvent?)? loadingBuilder;

  const NetworkImageWithRetry({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorBuilder,
    this.loadingBuilder,
  });

  @override
  State<NetworkImageWithRetry> createState() => _NetworkImageWithRetryState();
}

class _NetworkImageWithRetryState extends State<NetworkImageWithRetry> {
  Uint8List? _imageBytes;
  bool _isLoading = true;
  Object? _error;
  StackTrace? _stackTrace;
  int _retryCount = 0;
  static const int _maxRetries = 3;
  
  // Shared HttpClient instance to avoid creating too many connections
  static HttpClient? _sharedClient;
  static int _activeRequests = 0;
  
  static HttpClient _getClient() {
    _sharedClient ??= HttpClient()
      ..connectionTimeout = const Duration(seconds: 30)
      ..idleTimeout = const Duration(seconds: 60)
      ..autoUncompress = false
      ..maxConnectionsPerHost = 6; // Limit concurrent connections per host
    
    return _sharedClient!;
  }

  @override
  void initState() {
    super.initState();
    _loadImageWithThrottle();
  }

  @override
  void didUpdateWidget(NetworkImageWithRetry oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _imageBytes = null;
      _isLoading = true;
      _error = null;
      _retryCount = 0;
      _loadImageWithThrottle();
    }
  }

  Future<void> _loadImageWithThrottle() async {
    // Add small delay to stagger concurrent requests and avoid overwhelming server
    if (_activeRequests > 3) {
      await Future.delayed(Duration(milliseconds: 100 * _retryCount));
    }
    
    _activeRequests++;
    try {
      await _loadImage();
    } finally {
      _activeRequests--;
    }
  }

  Future<void> _loadImage() async {
    HttpClient? client;
    HttpClientRequest? request;
    HttpClientResponse? response;
    
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final uri = Uri.parse(widget.imageUrl);
      client = _getClient();

      request = await client.getUrl(uri);
      
      // Force connection close after response to avoid Keep-Alive issues
      request.headers.set('Connection', 'close');
      request.headers.set('Accept', '*/*');
      request.headers.set('User-Agent', 'Flutter-Image-Loader/1.0');
      request.headers.set('Cache-Control', 'no-cache');

      response = await request.close().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timeout after 30 seconds', const Duration(seconds: 30));
        },
      );
      
      if (response.statusCode == 200) {
        // Read ALL bytes from the response stream with timeout protection
        final bytes = <int>[];
        final contentLength = response.contentLength;
        
        // Use a completer to handle stream reading with better error control
        final completer = Completer<void>();
        final subscription = response.listen(
          (chunk) {
            bytes.addAll(chunk);
          },
          onError: (error) {
            if (!completer.isCompleted) {
              completer.completeError(error);
            }
          },
          onDone: () {
            if (!completer.isCompleted) {
              completer.complete();
            }
          },
          cancelOnError: false,
        );
        
        // Wait for stream to complete with timeout
        await completer.future.timeout(
          const Duration(seconds: 60),
          onTimeout: () {
            subscription.cancel();
            throw TimeoutException('Stream reading timeout after 60 seconds', const Duration(seconds: 60));
          },
        );
        
        // Validate we received the complete image
        if (contentLength > 0 && bytes.length != contentLength) {
          AppLogger.debug('NetworkImageWithRetry: Incomplete data - received ${bytes.length} bytes, expected $contentLength bytes');
          // If we got at least 90% of the data, try to use it (some servers don't send exact Content-Length)
          if (bytes.length < (contentLength * 0.9).round()) {
            throw Exception('Incomplete image data: received ${bytes.length} bytes, expected $contentLength bytes');
          }
        }
        
        if (mounted && bytes.isNotEmpty) {
          // Only set image if we have complete data
          setState(() {
            _imageBytes = Uint8List.fromList(bytes);
            _isLoading = false;
            _error = null;
          });
        } else {
          throw Exception('Empty response');
        }
      } else {
        throw Exception('Failed to load image: ${response.statusCode}');
      }
    } on TimeoutException catch (e, stackTrace) {
      AppLogger.error('NetworkImageWithRetry: Timeout loading image: ${widget.imageUrl}', e);
      _handleError(e, stackTrace);
    } on SocketException catch (e, stackTrace) {
      AppLogger.error('NetworkImageWithRetry: Socket error loading image: ${widget.imageUrl}', e);
      _handleError(e, stackTrace);
    } catch (e, stackTrace) {
      AppLogger.error('NetworkImageWithRetry: Error loading image: ${widget.imageUrl}', e);
      _handleError(e, stackTrace);
    } finally {
      // Response stream is automatically cleaned up when done
      // No manual cleanup needed
    }
  }
  
  Future<void> _handleError(Object error, StackTrace stackTrace) async {
    if (_retryCount < _maxRetries) {
      _retryCount++;
      AppLogger.debug('NetworkImageWithRetry: Retrying (${_retryCount}/$_maxRetries)...');
      // Exponential backoff with longer delays to give server time to recover
      await Future.delayed(Duration(milliseconds: 500 * _retryCount * _retryCount));
      _loadImage();
    } else {
      if (mounted) {
        setState(() {
          _error = error;
          _stackTrace = stackTrace;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      if (widget.loadingBuilder != null) {
        return widget.loadingBuilder!(
          context,
          SizedBox(
            width: widget.width,
            height: widget.height,
            child: const Center(child: CircularProgressIndicator()),
          ),
          null,
        );
      }
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _imageBytes == null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(context, _error ?? Exception('Unknown error'), _stackTrace);
      }
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Icon(Icons.error),
      );
    }

    return Image.memory(
      _imageBytes!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
    );
  }
}

