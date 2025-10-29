// package com.mohtm2;

// import io.flutter.embedding.engine.FlutterEngine;
// import io.flutter.plugin.common.MethodCall;
// import io.flutter.plugin.common.MethodChannel;
// import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingBackgroundService;

// public class BackgroundWidgetService extends FlutterFirebaseMessagingBackgroundService {
//     private static final String CHANNEL_NAME = "com.reda.mohtm2/widget_background";

//     @Override
//     protected void onHandleIntent(MethodCall call) {
//         if (call.method.equals("updateOccasionWidget")) {
//             // Your native code to update the widget goes here
//             // Example:
//             // Intent updateIntent = new Intent(this, YourAppWidgetProvider.class);
//             // updateIntent.setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE);
//             // AppWidgetManager.getInstance(this).sendBroadcast(updateIntent);
//             System.out.println("BackgroundWidgetService: updateOccasionWidget method called.");
//         }
//     }

//     @Override
//     public void onCreate() {
//         super.onCreate();
        
//         // This is a crucial step for setting up the background MethodChannel
//         FlutterEngine flutterEngine = getFlutterEngine();
//         if (flutterEngine != null) {
//             MethodChannel channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL_NAME);
//             channel.setMethodCallHandler(this::onHandleIntent);
//         }
//     }
// }