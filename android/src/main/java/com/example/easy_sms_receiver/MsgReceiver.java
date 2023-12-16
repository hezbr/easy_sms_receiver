package com.example.easy_sms_receiver;

import static android.provider.Telephony.Sms.Intents.SMS_RECEIVED_ACTION;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.provider.Telephony;
import android.telephony.SmsMessage;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodChannel;

public class MsgReceiver extends BroadcastReceiver {
    Context mcontext;
    
    @Override
    public void onReceive(Context context, Intent intent) {
        mcontext = context;
        System.out.println("EasySmsReceiver ::: Receive msg.");
        if (SMS_RECEIVED_ACTION.equals("android.provider.Telephony.SMS_RECEIVED")) {
            SmsMessage[] smsMessages = Telephony.Sms.Intents.getMessagesFromIntent(intent);
            handleMessage(smsMessages);
        }
    }

    void handleMessage(SmsMessage[] smsList) {
        Map<String, StringBuilder> messagesGroupedByOriginatingAddress = new HashMap<>();

        for (SmsMessage sms : smsList) {
            String address = sms.getOriginatingAddress();
            String messageBody = sms.getMessageBody();
            if (!messagesGroupedByOriginatingAddress.containsKey(address)) {
                messagesGroupedByOriginatingAddress.put(address, new StringBuilder());
            }
            messagesGroupedByOriginatingAddress.get(address).append(messageBody);
        }

        for (Map.Entry<String, StringBuilder> entry : messagesGroupedByOriginatingAddress.entrySet()) {
            String address = entry.getKey();
            String messages = entry.getValue().toString();

            // هنا يمكنك استخدام المتغير messages الذي يحتوي على جميع الرسائل المتجمعة للشخص الواحد
            System.out.println("Originating Address: " + address);
            System.out.println("Messages: " + messages);

            // send data into dart
            passMessageData(address, messages);
        }
    }

    void passMessageData(String address, String body){
        Map<String, String> message = new HashMap<>();
        message.put("address", address);
        message.put("body", body);
        EasySmsReceiverPlugin.channel.invokeMethod(Constants.onMessage, message);
    }
}
