import 'dart:convert';

import 'package:flutter/services.dart';

class ReturnReasonRepository {
  Future<List<String>> fetchReturnReasons() async {
    final String response =
        await rootBundle.loadString('assets/data/return-reasons.json');
    final List<dynamic> data = json.decode(response);
    return List<String>.from(data);
  }
}