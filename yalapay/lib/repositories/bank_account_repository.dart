import 'dart:convert';

import 'package:flutter/services.dart';

class BankAccountRepository {
  Future<List<dynamic>> getMap() async {
    final String response =
        await rootBundle.loadString('assets/data/bank-accounts.json');
    final data = json.decode(response);
    return data;
  }
}
