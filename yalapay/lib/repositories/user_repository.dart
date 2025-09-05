import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:yalapay/model/user.dart';

class UserRepository {
  List<User> users = [];

  Future<List<User>> getUsers() async {
    String data = await rootBundle.loadString('assets/data/users.json');
    var usersMap = jsonDecode(data);
    for (var userMap in usersMap) {
      users.add(User.fromJson(userMap));
    }
    return users;
  }
}
