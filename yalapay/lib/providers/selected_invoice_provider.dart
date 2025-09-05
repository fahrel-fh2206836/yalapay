import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalapay/model/cheque.dart';
import 'package:yalapay/model/invoice.dart';
import 'package:yalapay/model/payment.dart';

class SelectedInvoiceNotifier extends Notifier<Invoice> {
  @override
  Invoice build() {
    return Invoice(
        id: '',
        customerId: '',
        customerName: '',
        amount: 0,
        invoiceDate: '',
        dueDate: '');
  }

  void setInvoice(Invoice invoice) => state = invoice;

  void setDummy() {
    state = Invoice(
        id: '',
        customerId: '',
        customerName: '',
        amount: 0,
        invoiceDate: '',
        dueDate: '');
  }

  void resetInvoice(Invoice invoice) {
    setDummy();
    setInvoice(invoice);
  }

  void deletePayment(String id, List<Cheque> cheques) {
    state.removePayment(id, cheques);
  }

  void addNewPayment(Payment payment, List<Cheque> cheques) {
    state.addPayment(payment, cheques);
  }
}

final selectedInvoiceNotifierProvider =
    NotifierProvider<SelectedInvoiceNotifier, Invoice>(
        () => SelectedInvoiceNotifier());
