import 'dart:async';

import 'package:dio/dio.dart';
import 'package:dio_api_version_interceptor/dio_api_version_interceptor.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:test/test.dart';

void main() {
  StreamController<CompatibilityResult> controller =
      StreamController<CompatibilityResult>();
  Stream<CompatibilityResult> stream = controller.stream.asBroadcastStream();

  Dio dio = Dio(BaseOptions(baseUrl: 'https://someserver.com/api'))
    ..interceptors.add(ApiVersionHeaderInterceptor(
        streamController: controller, appVersion: '1.0.0'));
  DioAdapter dioAdapter = DioAdapter(dio: dio);

  group('Tests for Header interceptor responses', () {
    setUp(() {
      controller = StreamController<CompatibilityResult>();
      stream = controller.stream.asBroadcastStream();
      dio.interceptors.clear();
      dio.interceptors.add(ApiVersionHeaderInterceptor(
          streamController: controller, appVersion: '1.0.0'));

      dioAdapter.onGet(
        '/request100',
        (server) => server.reply(200, {
          'message': 'Success!'
        }, headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
          defaultApiVersionKey: ['1.0.0'],
        }),
      );
      dioAdapter.onGet(
        '/request101',
        (server) => server.reply(200, {
          'message': 'Success!'
        }, headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
          defaultApiVersionKey: ['1.0.1'],
        }),
      );
      dioAdapter.onGet(
        '/request111',
        (server) => server.reply(200, {
          'message': 'Success!'
        }, headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
          defaultApiVersionKey: ['1.1.1'],
        }),
      );
      dioAdapter.onGet(
        '/request110',
        (server) => server.reply(200, {
          'message': 'Success!'
        }, headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
          defaultApiVersionKey: ['1.1.0'],
        }),
      );
      dioAdapter.onGet(
        '/request211',
        (server) => server.reply(200, {
          'message': 'Success!'
        }, headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
          defaultApiVersionKey: ['2.1.1'],
        }),
      );
    });

    setUpFailure(String version, VersionSupportType supportType) {
      controller = StreamController<CompatibilityResult>();
      stream = controller.stream.asBroadcastStream();
      dio.interceptors.clear();
      dio.interceptors.add(ApiVersionHeaderInterceptor(
        streamController: controller,
        appVersion: version,
        minSupportedVersion: supportType,
      ));
    }

    tearDown(() async {});

    test(
        'StreamController adds a CompatibleVersion for the same version of API and app',
        () async {
      await dio.get('/request100');

      expect(stream, emitsInOrder([CompatibleVersion('1.0.0', '1.0.0')]));
    });

    test(
        'StreamController adds a CompatibleVersion when only api fix version is higher ',
        () async {
      await dio.get('/request101');
      expect(stream, emitsInOrder([CompatibleVersion('1.0.1', '1.0.0')]));
    });

    test(
        'StreamController adds a IncompatibleVersion when api minor version is higher  ',
        () async {
      await dio.get('/request110');
      expect(stream, emitsInOrder([IncompatibleVersion('1.1.0', '1.0.0')]));
    });
    test(
        'StreamController adds a IncompatibleVersion when api major version is higher  ',
        () async {
      await dio.get('/request211');
      expect(stream, emitsInOrder([IncompatibleVersion('2.1.1', '1.0.0')]));
    });
    test(
        'StreamController adds a IncompatibleVersion when api fix version is higher and tolerance is set to VersionSupportType.fix',
        () async {
      setUpFailure('1.0.0', VersionSupportType.fix);
      await dio.get('/request101');
      expect(stream, emitsInOrder([IncompatibleVersion('1.0.1', '1.0.0')]));
    });
  });
}
