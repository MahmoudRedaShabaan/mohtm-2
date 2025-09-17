package com.reda.mohtm2

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import io.flutter.embedding.android.FlutterFragmentActivity

// This is the correct change to ensure a robust lifecycle for notifications
class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "com.reda.mohtm2/widget"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "updateOccasionWidget" -> {
                    // Fallback custom action
                    val custom = Intent("com.reda.mohtm2.ACTION_UPDATE_OCCASION_WIDGET")
                    applicationContext.sendBroadcast(custom)

                    // Standard APPWIDGET_UPDATE broadcast with widget IDs
                    val appWidgetManager = AppWidgetManager.getInstance(applicationContext)
                    val componentName = ComponentName(applicationContext, com.reda.mohtm2.OccasionWidgetProvider::class.java)
                    val ids = appWidgetManager.getAppWidgetIds(componentName)
                    if (ids != null && ids.isNotEmpty()) {
                        val updateIntent = Intent(applicationContext, com.reda.mohtm2.OccasionWidgetProvider::class.java)
                        updateIntent.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                        updateIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
                        applicationContext.sendBroadcast(updateIntent)
                    }
                    result.success(null)
                }
                "updateTaskWidget" -> {
                    // Fallback custom action
                    val custom = Intent("com.reda.mohtm2.ACTION_UPDATE_TASK_WIDGET")
                    applicationContext.sendBroadcast(custom)

                    // Standard APPWIDGET_UPDATE broadcast with widget IDs
                    val appWidgetManager = AppWidgetManager.getInstance(applicationContext)
                    val componentName = ComponentName(applicationContext, com.reda.mohtm2.TaskWidgetProvider::class.java)
                    val ids = appWidgetManager.getAppWidgetIds(componentName)
                    if (ids != null && ids.isNotEmpty()) {
                        val updateIntent = Intent(applicationContext, com.reda.mohtm2.TaskWidgetProvider::class.java)
                        updateIntent.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                        updateIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
                        applicationContext.sendBroadcast(updateIntent)
                    }
                    result.success(null)
                }
                "updateReminderWidget" -> {
                    // Fallback custom action
                    val custom = Intent("com.reda.mohtm2.ACTION_UPDATE_REMINDER_WIDGET")
                    applicationContext.sendBroadcast(custom)

                    // Standard APPWIDGET_UPDATE broadcast with widget IDs
                    val appWidgetManager = AppWidgetManager.getInstance(applicationContext)
                    val componentName = ComponentName(applicationContext, com.reda.mohtm2.ReminderWidgetProvider::class.java)
                    val ids = appWidgetManager.getAppWidgetIds(componentName)
                    if (ids != null && ids.isNotEmpty()) {
                        val updateIntent = Intent(applicationContext, com.reda.mohtm2.ReminderWidgetProvider::class.java)
                        updateIntent.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                        updateIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
                        applicationContext.sendBroadcast(updateIntent)
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
