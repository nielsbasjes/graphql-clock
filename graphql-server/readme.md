# Spring for GraphQL

When the application is running, you can use GraphiQL as a web based GraphiQL client

GraphiQL url - http://localhost:8080/graphiql?path=/graphql

## Subscriptions

http://localhost:8080/graphiql?path=/graphql&wsPath=/graphql

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
