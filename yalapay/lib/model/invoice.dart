import 'package:yalapay/model/cheque.dart';
import 'package:yalapay/model/payment.dart';
import 'package:yalapay/utils/date_utils.dart';

class Invoice {
  String id;
  String customerId;
  String customerName;
  double amount;
  String invoiceDate; // yyyy-MM-dd
  String dueDate; // yyyy-MM-dd
  List<Payment> payments = [];
  double invoiceBalance;
  String status = 'Unpaid';

  Invoice({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.amount,
    required this.invoiceDate,
    required this.dueDate,
  }) : invoiceBalance = amount;

  Invoice.v2({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.amount,
    required this.invoiceDate,
    required this.dueDate,
    required this.invoiceBalance,
    required this.status,
  });

  void updateStatus() => status = invoiceBalance == 0
      ? 'Paid'
      : invoiceBalance == amount
          ? 'Unpaid'
          : 'Partially Paid';

  String getStatus() => status;

  void updateInvoiceBalance(List<Cheque> cheques) =>
      invoiceBalance = amount - calculateTotalPayment(cheques) < 0
          ? 0
          : amount - calculateTotalPayment(cheques);

  void addAllPayments(List<Payment> inComingPayments) {
    for (var payment in inComingPayments) {
      payments.add(payment);
    }
  }

  double calculateTotalPayment(List<Cheque> cheques) {
    final filteredCheques =
        cheques.where((cheque) => cheque.status == "Returned").toList();
    double total = 0;
    for (var payment in payments) {
      if (payment.paymentMode == "Cheque") {
        final cheque = cheques.firstWhere(
          (c) => c.chequeNo == payment.chequeNo,
          orElse: () => Cheque(
            chequeNo: -1,
            amount: 0,
            drawer: '',
            bankName: '',
            status: '',
            receivedDate: '',
            dueDate: '',
            chequeImageUri: '',
          ),
        );
        if (filteredCheques.contains(cheque)) continue;
      }
      total += payment.amount;
    }
    return total;
  }

  static double _toDouble(dynamic v, {double fallback = 0.0}) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }

  factory Invoice.fromJson(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'] as String,
      customerId: map['customerId'] as String,
      customerName: map['customerName'] as String,
      amount: _toDouble(map['amount']),
      invoiceDate: toYmdString(map['invoiceDate']),
      dueDate: toYmdString(map['dueDate']),
    );
  }

  factory Invoice.fromJson2(Map<String, dynamic> map) {
    return Invoice.v2(
      id: map['id'] as String,
      customerId: map['customerId'] as String,
      customerName: map['customerName'] as String,
      amount: _toDouble(map['amount']),
      invoiceDate: toYmdString(map['invoiceDate']),
      dueDate: toYmdString(map['dueDate']),
      invoiceBalance: _toDouble(map['invoiceBalance']),
      status: (map['status'] ?? 'Unpaid') as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'customerName': customerName,
        'amount': amount,
        'invoiceDate': ymdStringToDateTime(invoiceDate),
        'dueDate': ymdStringToDateTime(dueDate),
        'invoiceBalance': invoiceBalance,
        'status': status,
      };
}
