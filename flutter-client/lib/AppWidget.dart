import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:home_widget/home_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:time_client/client.dart';

GraphQLClient? _gqlClient;

void initializeAppHomeWidget(GraphQLClient gqlClient) {
  _gqlClient = gqlClient;
  if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) {
    WidgetsFlutterBinding.ensureInitialized();

    // Set the group ID (Needed for iOS)
    HomeWidget.setAppGroupId(appGroupId);
    HomeWidget.registerBackgroundCallback(backgroundCallback);

    updateWidget(null);
  }
}

// Called when Doing Background Work initiated from Widget
@pragma('vm:entry-point')
Future<void> backgroundCallback(Uri? uri) async {
  print('Received URI: $uri');

  _gqlClient ??= getGraphQLCLient();

  if (uri?.host == 'updatewidgetvalues') {
    final queryDocument = gql(
      r'''
      query {
        now {
          year
          month
          day
          hour
          minute
          second
          millisecond
          iso
        }
      }
    ''',
    );

    var queryResult = await _gqlClient!.query(QueryOptions(document: queryDocument));
    print(queryResult.toString());
    if (queryResult.hasException || queryResult.data == null) {
      updateWidget(null);
    } else {

      var data = queryResult.data!['now'];
      if (data == null) {
        updateWidget(null);
      }
      print('Using data: $data');
      updateWidget(data);
    }
  }
}

const String appGroupId = '<YOUR APP GROUP>';

// These are CLASS names!
const String iOSWidgetName = 'ClockWidgets';
const String androidWidgetName = 'ClockWidget';

var f2 = NumberFormat("00", "en_US");
var f3 = NumberFormat("000", "en_US");
var f4 = NumberFormat("0000", "en_US");

void updateWidget(var payload) {
  if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) {
    if (payload != null) {
      int year = payload['year'];
      int month = payload['month'];
      int day = payload['day'];
      int hour = payload['hour'];
      int minute = payload['minute'];
      int second = payload['second'];
      int millisecond = payload['millisecond'];
      String iso = payload['iso'];

      String date = '${f4.format(year)}-${f2.format(month)}-${f2.format(day)}';
      String time = '${f2.format(hour)}:${f2.format(minute)}:${f2.format(
          second)}.${f3.format(millisecond)}';

      HomeWidget.saveWidgetData<String>('date', date);
      HomeWidget.saveWidgetData<String>('time', time);
    } else {
      HomeWidget.saveWidgetData<String>('date', 'No Date');
      HomeWidget.saveWidgetData<String>('time', 'No Time');
    }
    HomeWidget.updateWidget(
      iOSName: iOSWidgetName,
      androidName: androidWidgetName,
    );
  }
}