import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:yalapay/model/cheque_deposit.dart';

class ChequeDepositRepo {
  List<ChequeDeposit> chequesDeposits = [];

  Future<List<ChequeDeposit>> getChequesDeposits() async {
    String data =
        await rootBundle.loadString('assets/data/cheque-deposits.json');
    var chequesMap = jsonDecode(data);
    for (var chequeMap in chequesMap) {
      chequesDeposits.add(ChequeDeposit.fromJson(chequeMap));
    }
    return chequesDeposits;
  }
}
