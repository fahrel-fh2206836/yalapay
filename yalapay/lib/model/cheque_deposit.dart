import 'package:yalapay/utils/date_utils.dart';

class ChequeDeposit {
  String id;
  String depositDate; // yyyy-MM-dd
  String cashedDate; // yyyy-MM-dd (may be '')
  String bankAccountNo;
  String status; // Deposited, Cashed, Cash with Returns
  List<int> chequeNos;

  ChequeDeposit({
    required this.id,
    required this.depositDate,
    required this.bankAccountNo,
    required this.status,
    required this.chequeNos,
    this.cashedDate = '',
  });

  static List<int> _toIntList(dynamic v) {
    if (v is List) {
      return v
          .map((e) {
            if (e is int) return e;
            if (e is num) return e.toInt();
            if (e is String) return int.tryParse(e) ?? -1;
            return -1;
          })
          .where((x) => x != -1)
          .toList();
    }
    return <int>[];
  }

  factory ChequeDeposit.fromJson(Map<String, dynamic> map) {
    return ChequeDeposit(
      id: map['id'] as String,
      depositDate: toYmdString(map['depositDate']),
      bankAccountNo: map['bankAccountNo'] as String,
      status: map['status'] as String,
      chequeNos: _toIntList(map['chequeNos']),
      cashedDate: toYmdString(map['cashedDate']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'depositDate': ymdStringToDateTime(depositDate),
        'bankAccountNo': bankAccountNo,
        'status': status,
        'chequeNos': chequeNos,
        'cashedDate':
            cashedDate.isEmpty ? null : ymdStringToDateTime(cashedDate),
      };
}
