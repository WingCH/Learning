import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:study_mockito/user_service.dart';

import 'mocks/user_service_test.mocks.dart';

@GenerateMocks([UserRepository])
void main() {
  group('UserService', () {
    late MockUserRepository mockRepository;
    late UserService userService;

    setUp(() {
      mockRepository = MockUserRepository();
      userService = UserService(mockRepository);
    });


    test('getUserName returns user name when user exists', () async {
      when(mockRepository.getUserById('123'))
          .thenAnswer((_) async => User(id: '123', name: 'John Doe'));

      final result = await userService.getUserName('123');

      expect(result, 'John Doe');
      verify(mockRepository.getUserById('123')).called(1);
    });

    test('getUserName returns "Unknown User" when user does not exist',
        () async {
      when(mockRepository.getUserById('456')).thenAnswer((_) async => null);

      final result = await userService.getUserName('456');

      expect(result, 'Unknown User');
      verify(mockRepository.getUserById('456')).called(1);
    });
  });
}
