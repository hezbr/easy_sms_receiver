import 'dart:async';
import 'dart:ui';

import 'package:easy_sms_receiver/easy_sms_receiver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    iosConfiguration: IosConfiguration(
      // autoStart: true,
      // onForeground: onStart,
      // onBackground: onBackground,
    ),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final plugin = EasySmsReceiver.instance;
  plugin.listenIncomingSms(
    onNewMessage: (message) {
      print("You have new message: ${message.body}");
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
            title: message.address ?? "address",
            content: message.body ?? "body");
      }
    },
  );
}
