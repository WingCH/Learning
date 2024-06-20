import 'package:graphql/client.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'numberOfReposQuery.graphql.dart';

const String YOUR_PERSONAL_ACCESS_TOKEN = 'xxxxx';

Future<void> main() async {
  final GraphQLClient client = GraphQLClient(
    cache: GraphQLCache(),
    link: HttpLink('https://api.github.com/graphql', defaultHeaders: {
      'Authorization': 'Bearer $YOUR_PERSONAL_ACCESS_TOKEN',
    }),
  );
  final result = await client.query$FetchRepositories(
    Options$Query$FetchRepositories(variables: Variables$Query$FetchRepositories(number_of_repos: 10)),
  );
  final data = result.parsedData;
  print(data?.toJson());
}
