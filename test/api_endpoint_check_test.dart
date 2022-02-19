import 'package:dio/dio.dart';
import 'package:dio_api_version_interceptor/dio_api_version_interceptor.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:test/test.dart';

void main() {
  Dio dio = Dio(BaseOptions(baseUrl: 'https://someserver.com/api'));
  DioAdapter dioAdapter = DioAdapter(dio: dio);

  group('Tests for Version Compatibility responses', () {
    setUp(() {
      dioAdapter.onGet('/compatible',
          (server) => server.reply(200, {'status': Results.compatible}),
          queryParameters: {'version': '1.0.0'});

      dioAdapter.onGet(
        '/warning',
        (server) => server.reply(200, {
          'status': Results.warning,
          'reason': 'Your app version might be obsolete'
        }),
        queryParameters: {'version': '1.0.0'},
      );
      dioAdapter.onGet(
        '/incompatible',
        (server) => server.reply(200, {
          'status': Results.incompatible,
          'reason': 'Api version is too far ahead!'
        }),
        queryParameters: {'version': '1.0.0'},
      );
    });
    test('Returns CompatibleAPIResult when app version is adequate', () async {
      final response = await dio.checkCompatibilityMapped(
        path: '/compatible',
        appVersion: '1.0.0',
      );
      expect(response, isA<CompatibleAPIResult>());
    });

    test('Returns WarningAPIResult when app version is adequate', () async {
      final response = await dio.checkCompatibilityMapped(
        path: '/warning',
        appVersion: '1.0.0',
      );
      expect(
        response,
        equals(
          WarningAPIResult(
              Results.warning, 'Your app version might be obsolete'),
        ),
      );
    });

    test('Returns IncompatibleAPIResult when app version is incompatible',
        () async {
      final response = await dio.checkCompatibilityMapped(
        path: '/incompatible',
        appVersion: '1.0.0',
      );
      expect(
        response,
        equals(
          IncompatibleAPIResult(
              Results.incompatible, 'Api version is too far ahead!'),
        ),
      );
    });

    test('Returns Map<String,dynamic> for checkCompatibility function',
        () async {
      final response = await dio.checkCompatibility(
        path: '/incompatible',
        appVersion: '1.0.0',
        deserializeFn: (Map<String, dynamic> json) {
          if (json['status'] == Results.compatible) {
            return CompatibleAPIResult.fromJson(json);
          }
          if (json['status'] == Results.warning) {
            return WarningAPIResult.fromJson(json);
          }
          return IncompatibleAPIResult.fromJson(json);
        },
      );

      expect(
        response,
        isA<CompatibilityApiResult>(),
      );

      expect(
        response,
        isA<IncompatibleAPIResult>(),
      );
    });
  });
}
