import 'dart:convert';
import 'package:flutter/services.dart';

class ChequeStatusRepository {
  Future<List<String>> fetchChequeStatuses() async {
    final String response =
        await rootBundle.loadString('assets/data/cheque-status.json');
    final List<dynamic> data = json.decode(response);
    return List<String>.from(data);
  }
}
