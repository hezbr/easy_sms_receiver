
# easy_sms_receiver


|*Note:* :exclamation:This plugin currently only works on Android Platform|
|------------------------------------------------------------------|

[![pub package](https://img.shields.io/badge/pub-0.0.1-blue.svg)](https://pub.dev/packages/easy_sms_receiver)

Flutter plugin to listen and read incoming SMS on Android

## Usage
To use this plugin add `easy_sms_receiver` as a [dependency in your pubspec.yaml file](https://flutter.dev/docs/development/packages-and-plugins/using-packages).

Add [permission_handler](https://pub.dev/packages/permission_handler) as a dependency in your project to request SMS permission.

Add [flutter_background_service](https://pub.dev/packages/flutter_background_service) as a dependency in your project to listen for incoming SMS in the background.


## Setup
Import the `easy_sms_receiver` package
```dart
import 'package:easy_sms_receiver/easy_sms_receiver.dart';
```


Retrieve the singleton instance of `easy_sms_receiver` by calling
```dart
final EasySmsReceiver easySmsReceiver = EasySmsReceiver.instance;
```

### Permissions
**This plugin requires SMS permission to be able to read incoming SMS.**

So use [permission_handler](https://pub.dev/packages/permission_handler) to request SMS permission:
```dart
final permissionStatus = await Permission.sms.request();
```
**Note:** The plugin will only request those permission that are listed in the `AndroidManifest.xml`
so you must add this permission to your `android/app/src/main/AndroidManifest.xml` file:
```xml
<manifest>
	<uses-permission android:name="android.permission.RECEIVE_SMS"/>

	<application>
		...
		...
	</application>
</manifest>
```


## Start the sms receiver to Listen to incoming SMS

*After add `RECEIVE_SMS` permission to your `AndroidManifest.xml` and request sms permission by [permission_handler](https://pub.dev/packages/permission_handler)*.

You can use the `listenIncomingSms` function to start listening for incoming SMS:

```dart
final easySmsReceiver = EasySmsReceiver.instance;
easySmsReceiver.listenIncomingSms(
  onNewMessage: (message) {
     // do something
  },
);
```

### Listen to incoming SMS in background
**You can use the [flutter_background_service](https://pub.dev/packages/flutter_background_service) plugin to listen for incoming SMS in the background as follow:


```dart
import 'package:flutter/material.dart';
import 'package:easy_sms_receiver/easy_sms_receiver.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

// function to initialize the background service
Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    iosConfiguration: IosConfiguration(),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
    ),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final plugin = EasySmsReceiver.instance;
  plugin.listenIncomingSms(
    onNewMessage: (message) {
      print("You have new message:");
      print("::::::Message Address: ${message.address}");
      print("::::::Message body: ${message.body}");

      // do something

      // for example: show notification
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: message.address ?? "address",
          content: message.body ?? "body",
        );
      }
    },
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // request the SMS permission, then initialize the background service
  Permission.sms.request().then((status) {
    if (status.isGranted) initializeService();
  });
  runApp(const MyApp());
}
```


## Stop the sms receiver

**You can stop the listening to incoming SMS by calling the `stopListenIncomingSms` function as follow:**

```dart
easySmsReceiver.stopListenIncomingSms();
```

*Look at the example*
