import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalapay/model/user.dart';
import 'package:yalapay/repositories/user_repository.dart';

class UserNotifier extends Notifier<List<User>> {
  final UserRepository _repo = UserRepository();
  @override
  build() {
    initializeUsers();
    return [];
  }

  void initializeUsers() async {
    List<User> users = await _repo.getUsers();
    state = users;
  }

  bool verifyUser(String email, String password) => state
      .where((user) => user.email == email && user.password == password)
      .toList()
      .isNotEmpty;

  User getUser(String email) => state.firstWhere((user) => user.email == email);
}

final userNotifierProvider =
    NotifierProvider<UserNotifier, List<User>>(() => UserNotifier());
