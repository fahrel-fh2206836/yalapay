import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalapay/model/payment.dart';
import 'package:yalapay/providers/repo_provider.dart';

import 'package:yalapay/repositories/yalapay_repo.dart';

class PaymentNotifier extends AsyncNotifier<List<Payment>> {
  late final YalapayRepo _repo;
  List<Payment> allPayments = [];

  @override
  Future<List<Payment>> build() async {
    _repo = await ref.watch(repoProvider.future);
    initializePayments();
    return [];
  }

  Future<void> initializePayments() async {
    _repo.observePayments().listen((payments) {
      state = AsyncData(payments);
      allPayments = List.from(payments);
    });
  }

  void addPayment(Payment payment) {
    _repo.addPayment(payment);
  }

  void removePayment(String id) {
    _repo.removePayment(id);
  }

  void showAllPayments() => initializePayments();

  Future<void> filterPaymentByAmount(double amount, String invoiceId) async {
    _repo.filterPaymentByAmount(amount, invoiceId).listen((payment) {
      state = AsyncData(payment);
    });
  }

  Future<void> filterPaymentByMode(String mode, String invoiceId) async {
    _repo.filterPaymentByMode(mode, invoiceId).listen((payment) {
      state = AsyncData(payment);
    });
  }

  Future<void> filterPaymentByDate(String dateString, String invoiceId) async {
    DateTime dateAfter = DateTime.parse(dateString);
    _repo.filterPaymentByDate(dateAfter, invoiceId).listen((payment) {
      state = AsyncData(payment);
    });
  }

  Future<void> getPaymentsByInvoiceId(String id) async {
    _repo.getPaymentsByInvoiceId(id).listen((payment) {
      state = AsyncData(payment);
    });
  }

  Future<Payment?> getPaymentWithChequeNo(int chequeNo) =>
      _repo.getPaymentWithChequeNo(chequeNo);
}

final paymentNotifierProvider =
    AsyncNotifierProvider<PaymentNotifier, List<Payment>>(
        () => PaymentNotifier());

// Payment Mode Provider
final paymentModeProvider = FutureProvider<List<String>>((ref) async {
  final repository = await ref.watch(yalaPayStaticRepoProvider.future);
  final modes = await repository.getPaymentMode();
  return modes.map((mode) => mode.paymentMode).toList();
});
