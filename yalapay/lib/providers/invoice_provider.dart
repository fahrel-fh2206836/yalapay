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

  Future<Map<String, double>> getAllInvoiceDuePendingBalance() async {
    final repo =
        _repo; // or: final repo = await ref.watch(repoProvider.future);

    final all = await repo.totalInvoiceBalanceAfterNow(openOnly: true);
    final due30 = await repo.totalInvoiceBalanceInNextDays(30, openOnly: true);
    final due60 = await repo.totalInvoiceBalanceInNextDays(60, openOnly: true);

    return {
      'All': all,
      'Due in 30 Days': due30,
      'Due in 60 Days': due60,
    };
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
