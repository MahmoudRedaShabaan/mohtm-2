package com.reda.mohtm2

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.content.ComponentName
import android.content.SharedPreferences
import android.widget.RemoteViews
import com.reda.mohtm2.R
import com.reda.mohtm2.MainActivity

class OccasionWidgetProvider : AppWidgetProvider() {
    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == "com.reda.mohtm2.ACTION_UPDATE_OCCASION_WIDGET") {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val thisWidget = ComponentName(context, OccasionWidgetProvider::class.java)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget)
            onUpdate(context, appWidgetManager, appWidgetIds)
        }
    }
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.occasion_widget)
            // Read detailed items stored by Flutter in SharedPreferences
            val prefs: SharedPreferences = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val json: String? = prefs.getString("flutter.widget_occasion_items", null)
            if (json != null && json.isNotEmpty()) {
                try {
                    val payload = org.json.JSONObject(json)
                    val items = payload.optJSONArray("items") ?: org.json.JSONArray()
                    val total = payload.optInt("total", items.length())
                    // Hide all by default
                    views.setViewVisibility(R.id.card_1, android.view.View.GONE)
                    views.setViewVisibility(R.id.card_2, android.view.View.GONE)
                    views.setViewVisibility(R.id.card_3, android.view.View.GONE)
                    views.setViewVisibility(R.id.more_count, android.view.View.GONE)

                    val max = kotlin.math.min(3, items.length())
                    for (i in 0 until max) {
                        val obj = items.getJSONObject(i)
                        val title = obj.optString("title")
                        val date = obj.optString("date")
                        val type = obj.optString("type")
                        val relationship = obj.optString("relationship")
                        val meta = listOf(date, type, relationship).filter { it.isNotEmpty() }.joinToString(" • ")
                        when (i) {
                            0 -> {
                                views.setTextViewText(R.id.item1_title, title)
                                views.setTextViewText(R.id.item1_meta, meta)
                                views.setViewVisibility(R.id.card_1, android.view.View.VISIBLE)
                            }
                            1 -> {
                                views.setTextViewText(R.id.item2_title, title)
                                views.setTextViewText(R.id.item2_meta, meta)
                                views.setViewVisibility(R.id.card_2, android.view.View.VISIBLE)
                            }
                            2 -> {
                                views.setTextViewText(R.id.item3_title, title)
                                views.setTextViewText(R.id.item3_meta, meta)
                                views.setViewVisibility(R.id.card_3, android.view.View.VISIBLE)
                            }
                        }
                    }
                    if (total > 3) {
                        views.setTextViewText(R.id.more_count, "+${total - 3} more")
                        views.setViewVisibility(R.id.more_count, android.view.View.VISIBLE)
                    }
                } catch (_: Exception) {
                    // ignore and keep default
                }
            }
            val intent = Intent(context, MainActivity::class.java)
            val pIntent = PendingIntent.getActivity(
                context, 1001, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_root, pIntent)
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}

class ReminderWidgetProvider : AppWidgetProvider() {
	override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == "com.reda.mohtm2.ACTION_UPDATE_REMINDER_WIDGET") {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val thisWidget = ComponentName(context, ReminderWidgetProvider::class.java)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget)
            onUpdate(context, appWidgetManager, appWidgetIds)
        }
    }
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.reminder_widget)
            val prefs: SharedPreferences = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val json: String? = prefs.getString("flutter.widget_reminder_items", null)
			if (json != null && json.isNotEmpty()) {
                try {
                    val payload = org.json.JSONObject(json)
                    val items = payload.optJSONArray("items") ?: org.json.JSONArray()
                    val total = payload.optInt("total", items.length())
                    // Hide all by default
                    views.setViewVisibility(R.id.card_1, android.view.View.GONE)
                    views.setViewVisibility(R.id.card_2, android.view.View.GONE)
                    views.setViewVisibility(R.id.card_3, android.view.View.GONE)
                    views.setViewVisibility(R.id.more_count, android.view.View.GONE)

                    val max = kotlin.math.min(3, items.length())
                    for (i in 0 until max) {
                        val obj = items.getJSONObject(i)
                        val title = obj.optString("title")
                        val date = obj.optString("date")
                        val repeat = obj.optString("repeat")
                        val meta = listOf(date, repeat).filter { it.isNotEmpty() }.joinToString(" • ")
                        when (i) {
                            0 -> {
                                views.setTextViewText(R.id.item1_title, title)
                                views.setTextViewText(R.id.item1_meta, meta)
                                views.setViewVisibility(R.id.card_1, android.view.View.VISIBLE)
                            }
                            1 -> {
                                views.setTextViewText(R.id.item2_title, title)
                                views.setTextViewText(R.id.item2_meta, meta)
                                views.setViewVisibility(R.id.card_2, android.view.View.VISIBLE)
                            }
                            2 -> {
                                views.setTextViewText(R.id.item3_title, title)
                                views.setTextViewText(R.id.item3_meta, meta)
                                views.setViewVisibility(R.id.card_3, android.view.View.VISIBLE)
                            }
                        }
                    }
                    if (total > 3) {
                        views.setTextViewText(R.id.more_count, "+${total - 3} more")
                        views.setViewVisibility(R.id.more_count, android.view.View.VISIBLE)
                    }
                } catch (_: Exception) {
                    // ignore and keep default
                }
            }
            val intent = Intent(context, MainActivity::class.java).apply { putExtra("route", "/reminders") }
            val pIntent = PendingIntent.getActivity(
                context, 1001, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_root, pIntent)
            appWidgetManager.updateAppWidget(appWidgetId, views)
			
        }
    }
}

class TaskWidgetProvider : AppWidgetProvider() {
	override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == "com.reda.mohtm2.ACTION_UPDATE_TASK_WIDGET") {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val thisWidget = ComponentName(context, TaskWidgetProvider::class.java)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget)
            onUpdate(context, appWidgetManager, appWidgetIds)
        }
    }
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            // Read detailed items stored by Flutter in SharedPreferences
			
            val views = RemoteViews(context.packageName, R.layout.task_widget)
            val prefs: SharedPreferences = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val json: String? = prefs.getString("flutter.widget_task_items", null)
			if (json != null && json.isNotEmpty()) {
                try {
                    val payload = org.json.JSONObject(json)
                    val items = payload.optJSONArray("items") ?: org.json.JSONArray()
                    val total = payload.optInt("total", items.length())
                    // Hide all by default
                    views.setViewVisibility(R.id.card_1, android.view.View.GONE)
                    views.setViewVisibility(R.id.card_2, android.view.View.GONE)
                    views.setViewVisibility(R.id.card_3, android.view.View.GONE)
                    views.setViewVisibility(R.id.more_count, android.view.View.GONE)

                    val max = kotlin.math.min(3, items.length())
                    for (i in 0 until max) {
                        val obj = items.getJSONObject(i)
                        val title = obj.optString("taskname")
                        val date = obj.optString("date")
                        val stats = obj.optString("status")
                        val meta = listOf(date, stats).filter { it.isNotEmpty() }.joinToString(" • ")
                        when (i) {
                            0 -> {
                                views.setTextViewText(R.id.item1_title, title)
                                views.setTextViewText(R.id.item1_meta, meta)
                                views.setViewVisibility(R.id.card_1, android.view.View.VISIBLE)
                            }
                            1 -> {
                                views.setTextViewText(R.id.item2_title, title)
                                views.setTextViewText(R.id.item2_meta, meta)
                                views.setViewVisibility(R.id.card_2, android.view.View.VISIBLE)
                            }
                            2 -> {
                                views.setTextViewText(R.id.item3_title, title)
                                views.setTextViewText(R.id.item3_meta, meta)
                                views.setViewVisibility(R.id.card_3, android.view.View.VISIBLE)
                            }
                        }
                    }
                    if (total > 3) {
                        views.setTextViewText(R.id.more_count, "+${total - 3} more")
                        views.setViewVisibility(R.id.more_count, android.view.View.VISIBLE)
                    }
                } catch (_: Exception) {
                    // ignore and keep default
                }
            }
            val intent = Intent(context, MainActivity::class.java)
            val pIntent = PendingIntent.getActivity(
                context, 1001, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_root, pIntent)
            appWidgetManager.updateAppWidget(appWidgetId, views)
            
        }
    }
}


