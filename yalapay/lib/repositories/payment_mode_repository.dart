import 'dart:convert';
import 'package:flutter/services.dart';

class PaymentModeRepository {
  Future<List<String>> getPaymentModes() async {
    final String response =
        await rootBundle.loadString('assets/data/payment-modes.json');
    final List<dynamic> data = json.decode(response);
    return data.map((mode) => mode.toString()).toList();
  }
}
