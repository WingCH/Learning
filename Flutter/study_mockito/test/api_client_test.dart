import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:study_mockito/api_client.dart';

import 'mocks/api_client_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('ApiClient', () {
    late MockClient mockClient;
    late ApiClient apiClient;

    setUp(() {
      mockClient = MockClient();
      apiClient = ApiClient(mockClient);
    });

    test('fetchTodo returns todo when http call completes successfully', () async {
      final responseData = {
        "userId": 1,
        "id": 1,
        "title": "delectus aut autem",
        "completed": false
      };

      when(mockClient.get(Uri.parse('https://jsonplaceholder.typicode.com/todos/1')))
          .thenAnswer((_) async => http.Response(json.encode(responseData), 200));

      final result = await apiClient.fetchTodo();
      expect(result, equals(responseData));
    });

    test('fetchTodo throws an exception when http call completes with an error', () {
      when(mockClient.get(Uri.parse('https://jsonplaceholder.typicode.com/todos/1')))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      expect(apiClient.fetchTodo(), throwsException);
    });
  });
}