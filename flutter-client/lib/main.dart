import 'dart:math';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';

import 'package:time_client/AppWidget.dart';
import 'package:fl_chart/fl_chart.dart';

import 'client.dart';

late GraphQLClient gqlClient;

void main() {
  gqlClient = getGraphQLCLient();
  initializeAppHomeWidget(gqlClient);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: ValueNotifier(gqlClient),
      child: MaterialApp(
        title: 'Flutter GraphQL subscription demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Flutter GraphQL subscription demo'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            children: [
              timeSubscription(),
              measurementSubscription(),
            ],
          )
        )
    );
  }

  int year = 0;
  int month = 0;
  int day = 0;
  int hour = 0;
  int minute = 0;
  int second = 0;
  int millisecond = 0;
  String iso = "Nothing yet";

  final timeSubscriptionDocument = gql(
    r'''
      subscription {
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

  var f2 = NumberFormat("00", "en_US");
  var f3 = NumberFormat("000", "en_US");
  var f4 = NumberFormat("0000", "en_US");

  Widget timeSubscription() {
    return Subscription(
        options: SubscriptionOptions(
          document: timeSubscriptionDocument,
        ),
        builder: (result) {
          if (result.hasException) {
            return Text(result.exception.toString());
          }
          if (result.isLoading) {
            return Center(
                child: Column(
              children: <Widget>[
                const Text('Is Loading:'),
                Text('$result'),
                const CircularProgressIndicator(),
              ],
            ));
          }
          if (result.data == null) {
            return const Center(
              child: Text('There is no data ?!?!'),
            );
          }
          var payload = result.data!['now'];
          year = payload['year'];
          month = payload['month'];
          day = payload['day'];
          hour = payload['hour'];
          minute = payload['minute'];
          second = payload['second'];
          millisecond = payload['millisecond'];
          iso = payload['iso'];

          updateWidget(payload);

          // ResultAccumulator is a provided helper widget for collating subscription results.
          // careful though! It is stateful and will discard your results if the state is disposed
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Current time:'),
              Text(
                '${f4.format(year)}-${f2.format(month)}-${f2.format(day)} ${f2.format(hour)}:${f2.format(minute)}:${f2.format(second)}.${f3.format(millisecond)}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          );
        });
  }

  int epoch = 0;
  double value = 0.0;

  static const limitCount = 100;
  final measurementPoints = <FlSpot>[];

  final measurementQueryDocument = gql(
    '''
      query {
        measurement(count: $limitCount) {
          epoch
          value
        }
      }
    ''',
  );

  final measurementSubscriptionDocument = gql(
    '''
      subscription {
        measurement {
          epoch
          value
        }
      }
    ''',
  );


  LineChartBarData line(List<FlSpot> points) {
    return LineChartBarData(
      spots: points,
      dotData: const FlDotData(
        show: false,
      ),
      color: const Color(0xFF2196F3),
      barWidth: 4,
      isCurved: false,
    );
  }


  void fillWithHistoricalData() async {
    QueryResult queryResult = await gqlClient.query(QueryOptions(document: measurementQueryDocument));
    if (queryResult.hasException) {
      return; // Cannot do anything
    }

    var rawPoints = queryResult.data!['measurement'];
    print('Got bootstrap payload: $rawPoints');

    for (var rawPoint in rawPoints) {
      var epoch = rawPoint['epoch'];
      var value = rawPoint['value'];
      var newSpot = FlSpot(epoch/1000.0, value);
      measurementPoints.add(newSpot);
    }

  }

  Widget measurementSubscription() {
    return Subscription(
        options: SubscriptionOptions(
          document: measurementSubscriptionDocument,
        ),
        builder: (result) {
          if (result.hasException) {
            return Text(result.exception.toString());
          }
          if (result.isLoading) {
            return Center(
                child: Column(
              children: <Widget>[
                const Text('Is Loading:'),
                Text('$result'),
                const CircularProgressIndicator(),
              ],
            ));
          }
          if (result.data == null) {
            return const Center(
              child: Text('There is no data ?!?!'),
            );
          }
          var payload = result.data!['measurement'];
          epoch = payload['epoch'];
          value = payload['value'];

          var newSpot = FlSpot(epoch/1000.0, value);

          if (measurementPoints.isEmpty) {
            fillWithHistoricalData();
            if (measurementPoints.last.x.compareTo(newSpot.x) != 0) {
              measurementPoints.add(newSpot);
            }
          } else {
            measurementPoints.add(newSpot);
          }

          while (measurementPoints.length > limitCount) {
            measurementPoints.removeAt(0);
          }
          // TODO: updateWidget(payload);

          // ResultAccumulator is a provided helper widget for collating subscription results.
          // careful though! It is stateful and will discard your results if the state is disposed
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Measurement value:'),
              Text(
                '${epoch} - ${value}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              measurementPoints.isNotEmpty ? AspectRatio(
                aspectRatio: 1.5,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: LineChart(
                    LineChartData(
                      minY: -2,
                      maxY: 2,
                      minX: measurementPoints.first.x,
                      maxX: measurementPoints.last.x,
                      lineTouchData: const LineTouchData(enabled: false),
                      clipData: const FlClipData.all(),
                      gridData: const FlGridData(
                        show: true,
                        drawVerticalLine: false,
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        line(measurementPoints),
                      ],
                      titlesData: const FlTitlesData(
                        show: false,
                      ),
                    ),
                  ),
                ),
              )
                  : const Text('No Measurements yet'),
            ],
          );
        });
  }
}
