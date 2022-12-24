package  com.gislayer.lokomedia.loko_media

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class HomeWidgetExampleProvider : HomeWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.example_layout).apply {

                val pendingIntentWithData1 = HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        Uri.parse("homeWidgetExample://message?photo"))
                setOnClickPendingIntent(R.id.photo, pendingIntentWithData1)

                val pendingIntentWithData2 = HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        Uri.parse("homeWidgetExample://message?video"))
                setOnClickPendingIntent(R.id.video, pendingIntentWithData2)

                val pendingIntentWithData3 = HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        Uri.parse("homeWidgetExample://message?audio"))
                setOnClickPendingIntent(R.id.audio, pendingIntentWithData3)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}