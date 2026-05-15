part of '../api_base.dart';

/// Interface for API implementations. Any class that implements this interface can be used as an API in the system.
/// Example usage:
/// ```dart
/// class MyApi implements ApiInterface {
/// ...
/// }
/// ```
abstract class Api with _ApiMonitor {
  const Api();

  void listener() {
    // Doing nothing
  }
}
