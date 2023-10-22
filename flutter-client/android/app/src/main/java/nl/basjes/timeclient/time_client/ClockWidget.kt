package nl.basjes.timeclient.time_client

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import android.net.Uri

/**
 * Implementation of App Widget functionality.
 */
class ClockWidget : HomeWidgetProvider() {
    override fun onUpdate(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetIds: IntArray,
            widgetData: SharedPreferences) {
        // There may be multiple widgets active, so update all of them
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId, widgetData)
        }
    }

    override fun onEnabled(context: Context) {
        // Enter relevant functionality for when the first widget is created
    }

    override fun onDisabled(context: Context) {
        // Enter relevant functionality for when the last widget is disabled
    }

    fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
            widgetData: SharedPreferences) {
        val date = widgetData.getString("date", "<NO DATE>")
        val time = widgetData.getString("time", "<NO TIME>")
        // Construct the RemoteViews object
        val views = RemoteViews(context.packageName, R.layout.clock_widget)
        views.setTextViewText(R.id.date, date)
        views.setTextViewText(R.id.time, time)

        // Open App on Widget Click
        val launchAppIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
        views.setOnClickPendingIntent(R.id.widget_root, launchAppIntent)

        // Pending intent to update counter on button click
        val updateWidgetValuesIntent = HomeWidgetBackgroundIntent.getBroadcast(context,
                Uri.parse("myAppWidget://updateWidgetValues"))
        views.setOnClickPendingIntent(R.id.refresh, updateWidgetValuesIntent)

        // Instruct the widget manager to update the widget
        appWidgetManager.updateAppWidget(appWidgetId, views)

    }
}