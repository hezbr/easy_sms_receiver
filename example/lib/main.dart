import 'package:easy_sms_receiver_example/back_services.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:easy_sms_receiver/easy_sms_receiver.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final EasySmsReceiver easySmsReceiver = EasySmsReceiver.instance;
  String _easySmsReceiverStatus = "Undefined";
  String _message = "";

  @override
  void initState() {
    super.initState();
  }

  Future<bool> requestSmsPermission() async {
    return await Permission.sms.request().then(
      (PermissionStatus pStatus) {
        if (pStatus.isPermanentlyDenied) {
          // "You must allow sms permission"
          openAppSettings();
        }
        return pStatus.isGranted;
      },
    );
  }

  Future<void> startSmsReceiver() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    if (await requestSmsPermission()) {
      easySmsReceiver.listenIncomingSms(
        onNewMessage: (message) {
          print("You have new message:");
          print("::::::Message Address: ${message.address}");
          print("::::::Message body: ${message.body}");

          if (!mounted) return;

          setState(() {
            _message = message.body ?? "Error reading message body.";
          });
        },
      );

      // If the widget was removed from the tree while the asynchronous platform
      // message was in flight, we want to discard the reply rather than calling
      // setState to update our non-existent appearance.
      if (!mounted) return;

      setState(() {
        _easySmsReceiverStatus = "Running";
      });
    }
  }

  void stopSmsReceiver() {
    easySmsReceiver.stopListenIncomingSms();
    if (!mounted) return;

    setState(() {
      _easySmsReceiverStatus = "Stopped";
    });
  }

  final plugin = EasySmsReceiver.instance;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Latest Received SMS: $_message"),
              Text('EasySmsReceiver Status: $_easySmsReceiverStatus\n'),
              TextButton(
                  onPressed: startSmsReceiver, child: Text("Start Receiver")),
              TextButton(
                  onPressed: stopSmsReceiver, child: Text("Stop Receiver")),
            ],
          ),
        ),
      ),
    );
  }
}
