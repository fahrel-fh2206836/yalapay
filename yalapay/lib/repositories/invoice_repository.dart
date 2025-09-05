import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:yalapay/model/cheque.dart';
import 'package:yalapay/model/invoice.dart';
import 'package:yalapay/model/payment.dart';
import 'package:yalapay/repositories/cheque_repository.dart';
import 'package:yalapay/repositories/payment_repository.dart';

class InvoiceRepository {
  List<Invoice> invoices = [];

  Future<List<Invoice>> getInvoices() async {
    String data = await rootBundle.loadString('assets/data/invoices.json');
    var invoicesMap = jsonDecode(data);
    for (var invoiceMap in invoicesMap) {
      invoices.add(Invoice.fromJson(invoiceMap));
    }
    List<Payment> payments = await PaymentRepository().getPayments();
    List<Cheque> cheques = await ChequeRepository().getCheques();

    for (var invoice in invoices) {
      List<Payment> invoicePayments =
          payments.where((payment) => payment.invoiceNo == invoice.id).toList();
      invoice.addAllPayments(invoicePayments);
      invoice.updateInvoiceBalance(cheques);
      invoice.updateStatus();
    }
    return invoices;
  }
}
