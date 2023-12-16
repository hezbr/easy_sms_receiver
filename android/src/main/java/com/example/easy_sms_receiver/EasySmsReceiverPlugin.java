package com.example.easy_sms_receiver;

import androidx.annotation.NonNull;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.IntentFilter;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.util.GeneratedPluginRegister;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** EasySmsReceiverPlugin */
public class EasySmsReceiverPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native
  /// Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine
  /// and unregister it
  /// when the Flutter Engine is detached from the Activity
  public static MethodChannel channel;

  /// الخاص بالتطبيق حتى يتم استخدامه context متغير لتخزين قيمة الـ
  /// service لتسجيل وبدء عمل الـ
  private Context mContext;

  /// تعريف كائن من مستقبل الرسائل حتى يتم استخدام هذا الكائن لتسجيل المستقبل
  /// وكذلك الغاء تسجيله
  private MsgReceiver msgReceiver = new MsgReceiver();


  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), Constants.easySmsReceiverChannel);
    channel.setMethodCallHandler(this);

    mContext = flutterPluginBinding.getApplicationContext();
  }



  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case Constants.startReceiverMethod:
        startReceiver();
        result.success(null);
        break;

      case Constants.stopReceiverMethod:
        stopReceiver();
        result.success(null);
        break;

      default:
        result.notImplemented();
        break;
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  public void startReceiver() {
    IntentFilter intent = new IntentFilter("android.provider.Telephony.SMS_RECEIVED");
    mContext.registerReceiver(msgReceiver, intent);
    System.out.println("::::::EasySmsReceiver - start receiver: ");
  }

  public void stopReceiver() {
    try {
      mContext.unregisterReceiver(msgReceiver);
      System.out.println("::::::EasySmsReceiver - stop receiver: ");
    } catch (Exception e) {
      System.out.println(":::::::EasySmsReceiver Exception: " + e.toString());
    }
  }
}
