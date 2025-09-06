import 'package:yalapay/utils/date_utils.dart';

class Payment {
  String id;
  String invoiceNo;
  double amount;
  String paymentDate; // yyyy-MM-dd
  String paymentMode;
  int chequeNo;

  Payment({
    required this.id,
    required this.invoiceNo,
    required this.amount,
    required this.paymentDate,
    required this.paymentMode,
    this.chequeNo = -1,
  });

  static double _toDouble(dynamic v, {double fallback = 0.0}) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }

  static int _toInt(dynamic v, {int fallback = -1}) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  factory Payment.fromJson(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] as String,
      invoiceNo: map['invoiceNo'] as String,
      amount: _toDouble(map['amount']),
      paymentDate: toYmdString(map['paymentDate']),
      paymentMode: map['paymentMode'] as String,
      chequeNo: _toInt(map['chequeNo']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'invoiceNo': invoiceNo,
        'amount': amount,
        'paymentDate': ymdStringToDateTime(paymentDate),
        'paymentMode': paymentMode,
        'chequeNo': chequeNo,
      };
}
