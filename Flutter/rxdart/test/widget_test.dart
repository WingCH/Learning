// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart/rxdart.dart';

class User {
  final String name;
  final int age;

  User({required this.name, required this.age});

  @override
  String toString() {
    return 'User('
        'name: $name, '
        'age: $age'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return other is User && other.name == name && other.age == age;
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      name,
      age,
    );
  }
}

void main() {
  test('Observables', () {
    // final numbers = [1, 2, 3, 5, 6, 7];
    // final stream = Stream.fromIterable(numbers);
    // Stream a = stream.where((event) => event % 2 == 0);
    final sourceSubject = BehaviorSubject<List<User>>.seeded([]);

    Stream<User?> wingStream = sourceSubject.flatMap<User?>((value) {
      return Stream<User?>.value(
        value.firstWhereOrNull(
          (element) {
            return element.name == 'wing';
          },
        ),
      );
    });

    sourceSubject.listen((userList) {
      print("sourceSubject: $userList");
    });

    wingStream.distinct().listen((user) {
      print("wingStream: $user");
    });

    sourceSubject.value = [User(name: 'a', age: 1)];
    sourceSubject.value = [User(name: 'wing', age: 25)];
    sourceSubject.value = [User(name: 'wing', age: 24)];
    sourceSubject.value = [User(name: 'wing', age: 24)];
  });
}
