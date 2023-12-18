import 'package:flutter/services.dart';

part 'constant.dart';

typedef MessageHandler = Function(SmsMessage message);

class EasySmsReceiver {
  final _channel = const MethodChannel(PLUGIN_CHANNEL);
  late MessageHandler _onNewMessage;

  static final _instance = EasySmsReceiver._newInstance();

  static EasySmsReceiver get instance => _instance;

  EasySmsReceiver._newInstance() {
    _channel.setMethodCallHandler(_handler);
  }

  void listenIncomingSms({required MessageHandler onNewMessage}) {
    _startMsgService();
    _onNewMessage = onNewMessage;
  }

  void stopListenIncomingSms() {
    _stopMsgService();
  }

  void _startMsgService() {
    _channel.invokeMethod<String?>(START_RECEIVER_METHOD);
  }

  void _stopMsgService() async {
    _channel.invokeMethod<String?>(STOP_RECEIVER_METHOD);
  }

  /// ## Do not call this method. This method is visible only for testing.
  // @visibleForTesting
  Future<dynamic> _handler(MethodCall call) async {
    switch (call.method) {
      case ON_MESSAGE_METHOD:
        final message = (call.arguments as Map).cast<String, dynamic>();
        // print(":::::::::on-message the message: ${message.body}");
        return _onNewMessage(SmsMessage.fromMap(message));
    }
  }
}

class SmsMessage {
  String? address;
  String? body;

  SmsMessage.fromMap(Map<String, dynamic> message) {
    address = message['address'];
    body = message['body'];
  }
}
