import 'package:dio/dio.dart';
import 'package:dio_api_version_interceptor/dio_api_version_interceptor.dart';

extension ApiEndpointCheckVersion on Dio {
  /// Returns the result of api call to check the version.
  ///
  /// [path] is the URL the endpoint that returns the response for `GET` request
  ///
  /// [appVersion] is the app version string, for example `'1.0.0'`
  ///
  /// [queryParamKey] is the query parameter name, default is `'version'`
  ///
  /// [deserializeFn] is the function callback to deserialize the response `JSON`

  Future<T> checkCompatibility<T>({
    required String path,
    required String appVersion,
    String queryParamKey = 'version',
    required T Function(Map<String, dynamic> json) deserializeFn,
  }) =>
      get(path, queryParameters: {queryParamKey: appVersion}).then(
        (value) => deserializeFn(value.data),
      );

  /// Returns the result of api call to check the version, mapped into `Equatable` classes
  ///
  /// [path] is the URL the endpoint that returns the response for `GET` request
  ///
  /// [appVersion] is the app version string, for example `'1.0.0'`
  ///
  /// [queryParamKey] is the query parameter name, default is `'version'`
  ///
  /// `CompatibilityApiResult` can be of types `CompatibleAPIResult`,`WarningAPIResult` or `IncompatibleAPIResult`
  Future<CompatibilityApiResult> checkCompatibilityMapped({
    required String path,
    required String appVersion,
    String queryParamKey = 'version',
  }) async {
    final result = await get<Map<String, dynamic>>(path,
        queryParameters: {queryParamKey: appVersion});

    if (result.data!['status'] == Results.compatible) {
      return CompatibleAPIResult.fromJson(result.data!);
    }
    if (result.data!['status'] == Results.warning) {
      return WarningAPIResult.fromJson(result.data!);
    }

    return IncompatibleAPIResult.fromJson(result.data!);
  }
}
