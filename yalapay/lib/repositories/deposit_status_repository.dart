import 'dart:convert';

import 'package:flutter/services.dart';

class DepositStatusRepository {
  Future<List<String>> getDepositStatus() async {
    String response = await rootBundle.loadString("assets/data/deposit-status.json");
    final List<dynamic> data = jsonDecode(response);
    return List<String>.from(data);
  }
}