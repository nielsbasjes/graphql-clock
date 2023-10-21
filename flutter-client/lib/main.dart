import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';

import 'client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
        client: getGraphQLCLient(),
        child: MaterialApp(
          title: 'Flutter GraphQL Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
            useMaterial3: true,
          ),
          home: const MyHomePage(title: 'Flutter GraphQL Demo Home Page'),
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
  int year = 0;
  int month = 0;
  int day = 0;
  int hour = 0;
  int minute = 0;
  int second = 0;
  int millisecond = 0;
  String iso = "Nothing yet";

  final subscriptionDocument = gql(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Subscription(
          options: SubscriptionOptions(
            document: subscriptionDocument,
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
                )
              );
            }
            if (result.data == null) {
              return const Center(
                  child: Text('There is no data ?!?!'),
              );
            }
            var payload = result.data!['now'];
            year         = payload['year'];
            month        = payload['month'];
            day          = payload['day'];
            hour         = payload['hour'];
            minute       = payload['minute'];
            second       = payload['second'];
            millisecond  = payload['millisecond'];
            iso          = payload['iso'];

            var f2 = NumberFormat("00", "en_US");
            var f3 = NumberFormat("000", "en_US");
            var f4 = NumberFormat("0000", "en_US");

            // ResultAccumulator is a provided helper widget for collating subscription results.
            // careful though! It is stateful and will discard your results if the state is disposed
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('Current time:'),
                Text('${f4.format(year)}-${f2.format(month)}-${f2.format(day)} ${f2.format(hour)}:${f2.format(minute)}:${f2.format(second)}.${f3.format(millisecond)}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            );
          }
      ),
    )
    );
  }
}
