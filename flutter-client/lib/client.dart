import 'package:flutter/cupertino.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

GraphQLClient getGraphQLCLient() {
  const String baseLink = 'epoch.klokko.nl/graphql';
  // const String _token = "Dummy value";

  final Link httpLink =
  HttpLink(
    'https://$baseLink',
  );// .concat(AuthLink(getToken: () => _token));

  final WebSocketLink websocketLink =
  WebSocketLink(
    'wss://$baseLink',
    subProtocol: GraphQLProtocol.graphqlTransportWs,
    config: const SocketClientConfig(
      autoReconnect: true,
      inactivityTimeout: Duration(seconds: 30),
      // initialPayload: () => async {
      //   return {
      //     'headers': {'Authorization': _token},
      //   };
      // },
    ),
  );

  final Link link = Link.split((request) => request.isSubscription, websocketLink, httpLink);

   return
    GraphQLClient(
      link: link,
      cache: GraphQLCache(), // The default store is the InMemoryStore, which does NOT persist to disk
    );

}