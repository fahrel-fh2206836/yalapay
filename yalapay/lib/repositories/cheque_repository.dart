import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:yalapay/model/cheque.dart';

class ChequeRepository {
  List<Cheque> cheques = [];

  Future<List<Cheque>> getCheques() async {
    String data = await rootBundle.loadString('assets/data/cheques.json');
    var chequesMap = jsonDecode(data);
    for (var chequeMap in chequesMap) {
      cheques.add(Cheque.fromJson(chequeMap));
    }
    return cheques;
  }

  void addCheque(Cheque cheque) => cheques.add(cheque);
  void removeCheque(int chequeNo) =>
      cheques.removeWhere((cheque) => cheque.chequeNo == chequeNo);
}
