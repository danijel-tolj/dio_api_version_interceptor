## Installation

```yaml
    dependencies:
        dio_api_version_interceptor: [version]
```

## Usage

Import the library

```dart 
import 'package:state_notifier_test.dart';
```

You can use an explicit call to the endpoint to check the version compatibility.

```dart
 final dio = Dio(BaseOptions(baseUrl: 'https://run.mocky.io'));
 return dio.checkCompatibilityMapped(
    path: '/v3/bb2dd989-d94a-46b8-9cdc-76d32a979dc3',
    appVersion: appVersion,
  );
```

Or you can use the Header Interceptor to check version on every response

```dart
 final interceptor = ApiVersionHeaderInterceptor(
    streamController: headerResultController,
    appVersion: appVersion,
    minSupportedVersion: VersionSupportType.minor,
  );
  dio = Dio(BaseOptions(baseUrl: 'https://run.mocky.io'))
    ..interceptors.add(interceptor);

  return headerResultController.stream;
```


