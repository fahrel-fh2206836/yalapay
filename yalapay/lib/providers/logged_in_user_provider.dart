import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalapay/model/user.dart';

class LoggedInUserNotifier extends Notifier<User> {
  bool isRememberMeChecked = false;

  @override
  User build() {
    return User(email: '', password: '', firstName: '', lastName: '');
  }

  void setUser(User user, {bool rememberMe = false}) {
    state = user;
    isRememberMeChecked = rememberMe;
  }

  void clearUser() {
    if (!isRememberMeChecked) {
      state = User(email: '', password: '', firstName: '', lastName: '');
    }
  }
}

final loggedInUserNotifierProvider =
    NotifierProvider<LoggedInUserNotifier, User>(() => LoggedInUserNotifier());
