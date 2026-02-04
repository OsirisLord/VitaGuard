import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Service to check network connectivity.
abstract class NetworkInfo {
  /// Checks if the device has an active internet connection.
  Future<bool> get isConnected;

  /// Stream of connectivity changes.
  Stream<bool> get onConnectivityChanged;
}

/// Implementation of NetworkInfo using connectivity_plus and internet_connection_checker_plus.
class NetworkInfoImpl implements NetworkInfo {
  final InternetConnection _internetConnection;

  NetworkInfoImpl({
    InternetConnection? internetConnection,
  }) : _internetConnection = internetConnection ?? InternetConnection();

  @override
  Future<bool> get isConnected async {
    return await _internetConnection.hasInternetAccess;
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return _internetConnection.onStatusChange.map(
      (status) => status == InternetStatus.connected,
    );
  }
}
