class User {
  final String id;
  final String name;

  User({required this.id, required this.name});
}

abstract class UserRepository {
  Future<User?> getUserById(String id);
}

class UserService {
  final UserRepository repository;

  UserService(this.repository);

  Future<String> getUserName(String id) async {
    final user = await repository.getUserById(id);
    return user?.name ?? 'Unknown User';
  }
}
