import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:yalapay/model/payment.dart';

class PaymentRepository {
  List<Payment> payments = [];

  Future<List<Payment>> getPayments() async {
    String data = await rootBundle.loadString('assets/data/payments.json');
    var paymentsMap = jsonDecode(data);
    for (var paymentMap in paymentsMap) {
      payments.add(Payment.fromJson(paymentMap));
    }
    return payments;
  }

  void addPayment(Payment payment) => payments.add(payment);

  void removePayment(String id) =>
      payments.removeWhere((payment) => payment.id == id);
}
