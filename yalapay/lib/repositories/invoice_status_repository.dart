import 'dart:convert';
import 'package:flutter/services.dart';

class InvoiceStatusRepository {
  Future<List<String>> fetchInvoiceStatuses() async {
    final String response =
        await rootBundle.loadString('assets/data/invoice-status.json');
    final List<dynamic> data = json.decode(response);
    return List<String>.from(data);
  }
}
