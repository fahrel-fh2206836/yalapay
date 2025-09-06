import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalapay/model/invoice.dart';
import 'package:yalapay/model/payment.dart';
import 'package:yalapay/providers/cheque_provider.dart';
import 'package:yalapay/providers/payment_provider.dart';
import 'package:yalapay/providers/repo_provider.dart';
import 'package:yalapay/repositories/yalapay_repo.dart';

class SelectedInvoiceNotifier extends AsyncNotifier<Invoice> {
  late final YalapayRepo _repo;
  @override
  Future<Invoice> build() async {
    _repo = await ref.watch(repoProvider.future);
    return Invoice(
        id: '',
        customerId: '',
        customerName: '',
        amount: 0,
        invoiceDate: '',
        dueDate: '');
  }

  void setInvoice(Invoice invoice) async {
    _repo.observeInvoiceById(invoice.id).listen((selectedInvoice) {
      List<Payment> invoicePayments = ref
          .read(paymentNotifierProvider.notifier)
          .allPayments
          .where((payment) => payment.invoiceNo == selectedInvoice!.id)
          .toList();
      selectedInvoice?.addAllPayments(invoicePayments);
      selectedInvoice?.updateInvoiceBalance(
          ref.read(chequeNotifierProvider.notifier).allCheques);
      selectedInvoice?.updateStatus();
      state = AsyncData(selectedInvoice!);
      invoice = selectedInvoice;
    });
  }
}

final selectedInvoiceNotifierProvider =
    AsyncNotifierProvider<SelectedInvoiceNotifier, Invoice>(
        () => SelectedInvoiceNotifier());
