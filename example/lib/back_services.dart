import 'dart:async';
import 'dart:ui';

import 'package:easy_sms_receiver/easy_sms_receiver.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

// function to initialize the background service
// call this function in main to initializeService to start 
// the sms listening in the background
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
