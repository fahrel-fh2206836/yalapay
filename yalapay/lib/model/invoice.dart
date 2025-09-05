import 'package:yalapay/model/cheque.dart';
import 'package:yalapay/model/payment.dart';

class Invoice {
  String id;
  String customerId;
  String customerName;
  double amount;
  String invoiceDate;
  String dueDate;
  List<Payment> payments = [];
  late double invoiceBalance;
  String status = 'Unpaid';

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
    List<Cheque> filteredCheques =
        cheques.where((cheque) => cheque.status == "Returned").toList();
    double total = 0;
    for (var payment in payments) {
      if (payment.paymentMode == "Cheque") {
        Cheque cheque = cheques.firstWhere(
          (cheque) => cheque.chequeNo == payment.chequeNo,
        );
        if (filteredCheques.contains(cheque)) {
          continue;
        }
      }
      total += payment.amount;
    }
    return total;
  }

  void removePayment(String id, List<Cheque> cheques) {
    payments.removeWhere((payment) => payment.id == id);
    updateInvoiceBalance(cheques);
    updateStatus();
  }

  void addPayment(Payment payment, List<Cheque> cheques) {
    payments.add(payment);
    updateInvoiceBalance(cheques);
    updateStatus();
  }

  Invoice(
      {required this.id,
      required this.customerId,
      required this.customerName,
      required this.amount,
      required this.invoiceDate,
      required this.dueDate})
      : invoiceBalance = amount;

  factory Invoice.fromJson(Map<String, dynamic> map) {
    return Invoice(
        id: map['id'],
        customerId: map['customerId'],
        customerName: map['customerName'],
        amount: map['amount'],
        invoiceDate: map['invoiceDate'],
        dueDate: map['dueDate']);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'customerName': customerName,
        'amount': amount,
        'invoiceDate': invoiceDate,
        'dueDate': dueDate
      };
}
