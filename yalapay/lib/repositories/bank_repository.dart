import 'dart:convert';

import 'package:flutter/services.dart';

class BankRepository {
  Future<List<String>> getBanks() async {
    final String response =
        await rootBundle.loadString('assets/data/banks.json');
    final List<dynamic> data = json.decode(response);
    return data.map((mode) => mode.toString()).toList();
  }
}
