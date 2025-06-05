# Sentry Configuration for Flutter

## 1. Add Dependencies

Add these dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  sentry_flutter: ^7.8.0

dev_dependencies:
  sentry_dart_plugin: ^1.1.1
```

## 2. Initialize Sentry in main.dart

Update your `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Sentry
  await SentryFlutter.init(
    (options) {
      options.dsn = 'YOUR_DSN_HERE';
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 0.1;
      // Enable performance monitoring
      options.enableAutoPerformanceTracing = true;
      // Enable automatic UI instrumentation
      options.enableAutoSessionTracking = true;
      // Set the release version
      options.release = 'com.banadoctor.app@1.0.0+1';
      // Set the environment
      options.environment = 'production';
    },
    // Your app initialization code goes here
    appRunner: () => runApp(MyApp()),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BanaDoctor',
      navigatorObservers: [
        // This observer will automatically send navigation events to Sentry
        SentryNavigatorObserver(),
      ],
      // ... rest of your app configuration
    );
  }
}
```

## 3. Error Reporting

### Capture Exceptions

```dart
try {
  // Your code that might throw
} catch (exception, stackTrace) {
  await Sentry.captureException(
    exception,
    stackTrace: stackTrace,
    withScope: (scope) {
      // Add custom context
      scope.setTag('page', 'home_screen');
      scope.setExtra('user_id', '12345');
    },
  );
  // Re-throw if needed
  rethrow;
}
```

### Capture Messages

```dart
await Sentry.captureMessage('Something went wrong', level: SentryLevel.warning);
```

## 4. Performance Monitoring

### Manual Transactions

```dart
final transaction = Sentry.startTransaction('load_user_data', 'api');
final span = transaction.startChild('network_request');

try {
  // Your async operation
  await fetchUserData();
  
  span.status = const SpanStatus.ok();
} catch (e) {
  span.throwable = e;
  span.status = const SpanStatus.internalError();
  rethrow;
} finally {
  await span.finish();
  await transaction.finish();
}
```

## 5. User Context

```dart
// Set user context
Sentry.configureScope((scope) {
  scope.setUser(SentryUser(
    id: 'user123',
    email: 'user@example.com',
    // Add any additional user data
    data: {
      'name': 'John Doe',
      'account_type': 'premium',
    },
  ));
});

// Clear user context on logout
Sentry.configureScope((scope) => scope.setUser(null));
```

## 6. Environment Variables

For security, use environment variables for sensitive data:

1. Create a `.env` file in your Flutter project root:
```
SENTRY_DSN=your_dsn_here
```

2. Add `.env` to your `.gitignore`

3. Use the `flutter_dotenv` package to load environment variables

## 7. Debug Information

For better stack traces, add this to your `android/app/build.gradle`:

```gradle
android {
    // ...
    buildTypes {
        release {
            // ...
            signingConfig signingConfigs.debug
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

Create `android/app/proguard-rules.pro`:

```
# Keep stack traces
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
```

## 8. Release Health

To track release health, ensure `enableAutoSessionTracking` is `true` in your Sentry initialization.
