import 'dart:async';

import 'package:dio/dio.dart';

import 'models/compatibility_result.dart';
part 'constants/constants.dart';
part 'enums/version_support_type.dart';

/// Response Interceptor for reading the compatibility of API with the App version
/// It will compare the api version from header with the app version on each api response
/// Version Strings should look like `1.0.0`
///
/// [headerApiVersionKey] is the header namer that will be read from the response
/// default value is `x-api-version`
///
/// [minSupportedVersion] is the minimal supported version level that will return a [CompatibleVersion]. Can be `major`,`minor` or `fix`
/// default value is `minor`
///
/// [streamController] is the [StreamController] which needs to be passed to the Interceptor
/// Results of the search will be added to its stream, they will be extensions of [CompatibilityResult]
/// Results can be [CompatibleVersion] or [IncompatibleVersion]
///
class ApiVersionHeaderInterceptor extends Interceptor {
  final String headerApiVersionKey;
  final String appVersion;
  final VersionSupportType minSupportedVersion;
  final StreamController<CompatibilityResult> streamController;

  ApiVersionHeaderInterceptor({
    this.headerApiVersionKey = defaultApiVersionKey,
    this.minSupportedVersion = VersionSupportType.minor,
    required this.streamController,
    required this.appVersion,
  });

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.headers.map.containsKey(headerApiVersionKey)) {
      final apiVersion = response.headers.map[headerApiVersionKey]!.first;
      final apiVersionParts = apiVersion.split('.').map((e) => int.parse(e));
      final appVersionParts = appVersion.split('.').map((e) => int.parse(e));

      streamController.add(
        _isSupportedVersion(
          apiVersionParts: apiVersionParts,
          appVersionParts: appVersionParts,
          minSupportedVersion: minSupportedVersion,
        )
            ? CompatibleVersion(apiVersion, appVersion)
            : IncompatibleVersion(apiVersion, appVersion),
      );
    }

    super.onResponse(response, handler);
  }
}

bool _isSupportedVersion(
    {required Iterable<int> apiVersionParts,
    required Iterable<int> appVersionParts,
    required VersionSupportType minSupportedVersion}) {
  switch (minSupportedVersion) {
    case VersionSupportType.major:
      return apiVersionParts.elementAt(0) <= appVersionParts.elementAt(0);
    case VersionSupportType.minor:
      return apiVersionParts.elementAt(0) <= appVersionParts.elementAt(0) &&
          apiVersionParts.elementAt(1) <= appVersionParts.elementAt(1);

    case VersionSupportType.fix:
      return apiVersionParts.elementAt(0) <= appVersionParts.elementAt(0) &&
          apiVersionParts.elementAt(1) <= appVersionParts.elementAt(1) &&
          apiVersionParts.elementAt(2) <= appVersionParts.elementAt(2);
  }
}
