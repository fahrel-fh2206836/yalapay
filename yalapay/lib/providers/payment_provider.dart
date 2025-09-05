import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalapay/model/payment.dart';
import 'package:yalapay/repositories/payment_repository.dart';

class PaymentNotifier extends Notifier<List<Payment>> {
  final PaymentRepository _repo = PaymentRepository();
  List<Payment> _allPayments = [];

  @override
  List<Payment> build() {
    initializePayments();
    return [];
  }

  Future<void> initializePayments() async {
    _allPayments = await _repo.getPayments();
    state = List.from(_allPayments);
  }

  void addPayment(Payment payment, [bool addRepo = true]) {
    _allPayments.add(payment);
    state = List.from(_allPayments);
    if (addRepo) {
      _repo.addPayment(payment);
    }
  }

  void removePayment(String id) {
    _allPayments.removeWhere((payment) => payment.id == id);
    state = List.from(_allPayments);
    _repo.removePayment(id);
  }

  void showAllPayments() {
    state = List.from(_allPayments);
  }

  void filterPaymentByAmount(double amount) {
    state = _allPayments.where((payment) => payment.amount >= amount).toList();
  }

  void filterPaymentByMode(String mode) {
    state =
        _allPayments.where((payment) => payment.paymentMode == mode).toList();
  }

  bool filterPaymentByDate(String dateString) {
    DateTime dateAfter = DateTime.parse(dateString);
    state = _allPayments
        .where(
            (payment) => DateTime.parse(payment.paymentDate).isAfter(dateAfter))
        .toList();
    return true;
  }

  Payment getPaymentWithChequeNo(int chequeNo) =>
      state.firstWhere((payment) => payment.chequeNo == chequeNo);

  List<Payment> tempPayments = [];

  void setSelectedPaymentList(List<Payment> payments) {
    tempPayments = [];
    for (var payment in payments) {
      tempPayments.add(payment);
    }
    state = payments;
  }
}

final paymentNotifierProvider =
    NotifierProvider<PaymentNotifier, List<Payment>>(() => PaymentNotifier());
