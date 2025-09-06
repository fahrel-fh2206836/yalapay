import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalapay/model/invoice.dart';
import 'package:yalapay/model/payment.dart';
import 'package:yalapay/providers/cheque_provider.dart';
import 'package:yalapay/providers/payment_provider.dart';
import 'package:yalapay/providers/repo_provider.dart';
import 'package:yalapay/repositories/yalapay_repo.dart';

class InvoiceNotifier extends AsyncNotifier<List<Invoice>> {
  late final YalapayRepo _repo;
  // late List<Invoice> invoiceList;

  @override
  Future<List<Invoice>> build() async {
    _repo = await ref.watch(repoProvider.future);
    initializeInvoices();
    return [];
  }

  void initializeInvoices() async {
    _repo.observeInvoices().listen((invoices) {
      for (var invoice in invoices) {
        List<Payment> invoicePayments = ref
            .read(paymentNotifierProvider.notifier)
            .allPayments
            .where((payment) => payment.invoiceNo == invoice.id)
            .toList();
        invoice.addAllPayments(invoicePayments);
        invoice.updateInvoiceBalance(
            ref.read(chequeNotifierProvider.notifier).allCheques);
        invoice.updateStatus();
      }
      state = AsyncData(invoices);
      // invoiceList = List.from(invoice);
    });
  }

  void filterById(String value) {
    _repo.filterInvoiceById(value).listen((invoice) {
      state = AsyncData(invoice);
    }).onError((error) => print(error));
  }

  void showAll() => initializeInvoices();

  void removeInvoice(String id) {
    _repo.deleteInvoice(id);
  }

  void addInvoice(Invoice invoice) {
    _repo.addInvoice(invoice);
  }

  Future<List<Invoice>> getInvoicesByCustId(String custId) =>
      _repo.getInvoicesByCustId(custId);

  void updateInvoiceCust(String custId, String newCompanyName) async {
    List<Invoice> customerInvoice = await _repo.getInvoicesByCustId(custId);
    for (var invoice in customerInvoice) {
      invoice.customerName = newCompanyName;
      _repo.updateInvoice(invoice);
    }
  }

  void updateInvoiceDue(String newDateString, String id) async {
    var invoice = await getInvoice(id);
    invoice!.dueDate = newDateString;
    _repo.updateInvoice(invoice);
  }

  void filterByDate(String dateFrom, String dateTo) {
    DateTime _dateFrom;
    DateTime _dateTo;

    if (dateTo.isEmpty) {
      _dateFrom = DateTime.parse("2024-10-02");
    } else {
      try {
        _dateFrom = DateTime.parse(dateFrom);
      } catch (e) {
        _dateFrom = DateTime.parse("2024-10-02");
        const SnackBar(content: Text("Error"));
      }
    }

    if (dateTo.isEmpty) {
      _dateTo = DateTime.now();
    } else {
      try {
        _dateTo = DateTime.parse(dateTo);
      } catch (e) {
        _dateTo = DateTime.now();
        const SnackBar(content: Text("Error"));
      }
    }

    _repo.filterInvoiceByDate(_dateFrom, _dateTo);
  }

  Future<double> getTotal() => _repo.getTotalAmountOfInvoices();

  Stream<List<Invoice>> filterByStatus(String status) =>
      _repo.filterInvoiceByStatus(status);

//  List<Invoice> getInvoiceList() => invoiceList;//Nott sure

  Future<Invoice?> getInvoice(String id) => _repo.getInvoiceById(id);

  Future<void> sortById() async {
    _repo.sortInvoicesById().listen((invoices) {
      state = AsyncData(invoices);
    });
  }
}

final invoiceNotifierProvider =
    AsyncNotifierProvider<InvoiceNotifier, List<Invoice>>(
        () => InvoiceNotifier());

//Invoice status provider
final invoiceStatusProvider = FutureProvider<List<String>>((ref) async {
  final repository = await ref.watch(yalaPayStaticRepoProvider.future);
  final invoiceStatues = await repository.getInvoiceStatus();
  return invoiceStatues.map((status) => status.invoiceStatus).toList();
});
