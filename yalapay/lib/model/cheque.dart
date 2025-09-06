import 'package:yalapay/utils/date_utils.dart';

class Cheque {
  int chequeNo;
  double amount;
  String drawer;
  String bankName;
  String status;
  String receivedDate; // yyyy-MM-dd
  String dueDate; // yyyy-MM-dd
  String chequeImageUri;
  String depositDate; // yyyy-MM-dd or ''
  String cashedDate; // yyyy-MM-dd or ''
  String returnedDate; // yyyy-MM-dd or ''
  String returnReason;

  Cheque({
    required this.chequeNo,
    required this.amount,
    required this.drawer,
    required this.bankName,
    required this.status,
    required this.receivedDate,
    required this.dueDate,
    required this.chequeImageUri,
    this.depositDate = '',
    this.cashedDate = '',
    this.returnedDate = '',
    this.returnReason = '',
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

  factory Cheque.fromJson(Map<String, dynamic> map) {
    return Cheque(
      chequeNo: _toInt(map['chequeNo']),
      amount: _toDouble(map['amount']),
      drawer: map['drawer'] as String,
      bankName: map['bankName'] as String,
      status: map['status'] as String,
      receivedDate: toYmdString(map['receivedDate']),
      dueDate: toYmdString(map['dueDate']),
      chequeImageUri: map['chequeImageUri'] as String,
      depositDate: toYmdString(map['depositDate']),
      cashedDate: toYmdString(map['cashedDate']),
      returnedDate: toYmdString(map['returnedDate']),
      returnReason: (map['returnReason'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'chequeNo': chequeNo,
        'amount': amount,
        'drawer': drawer,
        'bankName': bankName,
        'status': status,
        'receivedDate': ymdStringToDateTime(receivedDate),
        'dueDate': ymdStringToDateTime(dueDate),
        'chequeImageUri': chequeImageUri,
        'depositDate':
            depositDate.isEmpty ? null : ymdStringToDateTime(depositDate),
        'cashedDate':
            cashedDate.isEmpty ? null : ymdStringToDateTime(cashedDate),
        'returnedDate':
            returnedDate.isEmpty ? null : ymdStringToDateTime(returnedDate),
        'returnReason': returnReason,
      };
}
