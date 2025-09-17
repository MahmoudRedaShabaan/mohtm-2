# Flutter Local Notifications plugin rules
-keep class io.flutter.plugins.flutter_local_notifications.** { *; }
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Rules for the Gson library, which is used for serialization
-keep class com.google.gson.Gson
-keep class com.google.gson.TypeAdapter
-keep class com.google.gson.TypeAdapterFactory
-keep class com.google.gson.JsonSerializer
-keep class com.google.gson.JsonDeserializer

# Keep all classes that extend TypeAdapter, TypeAdapterFactory, etc.
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep the aop classes for the plugin
-keep class io.flutter.plugins.flutter_local_notifications.FlutterLocalNotificationsPlugin