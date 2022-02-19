import 'dart:async';

import 'package:dio/dio.dart';

import 'package:dio_api_version_interceptor/dio_api_version_interceptor.dart';

late Dio dio;
StreamController<CompatibilityResult> headerResultController =
    StreamController();
String appVersion = '1.0.0';

Future<void> main() async {
  final result = await checkApiIfCompatible();
  print(result);

  checkHeaderIfCompatible().listen((event) {
    print(event);
  });

  await dio.get('/v3/effe231a-5648-484d-a0a8-919a98fabd36');
  await dio.get('/v3/ff2fc409-b519-4fb6-881d-066655b934b9');
}

Future<CompatibilityApiResult> checkApiIfCompatible() async {
  return Dio(BaseOptions(baseUrl: 'https://run.mocky.io'))
      .checkCompatibilityMapped(
    path: '/v3/bb2dd989-d94a-46b8-9cdc-76d32a979dc3',
    appVersion: appVersion,
  );
}

Stream<CompatibilityResult> checkHeaderIfCompatible() {
  final interceptor = ApiVersionHeaderInterceptor(
    streamController: headerResultController,
    appVersion: appVersion,
    minSupportedVersion: VersionSupportType.minor,
  );
  dio = Dio(BaseOptions(baseUrl: 'https://run.mocky.io'))
    ..interceptors.add(interceptor);

  return headerResultController.stream;
}
