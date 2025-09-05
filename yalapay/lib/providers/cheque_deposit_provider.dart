import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalapay/model/cheque_deposit.dart';
import 'package:yalapay/repositories/cheque_deposit_repo.dart';

class ChequeDepositNotifier extends Notifier<List<ChequeDeposit>> {
  final ChequeDepositRepo _repo = ChequeDepositRepo();
  @override
  List<ChequeDeposit> build() {
    initializeChequeDeposit();
    return [];
  }

  void initializeChequeDeposit() async {
    List<ChequeDeposit> chequeDeposits = await _repo.getChequesDeposits();
    state = chequeDeposits;
  }

  List<int> getChequesList(String chequeDepositId) {
    return state.firstWhere((cd) => cd.id == chequeDepositId).chequeNos;
  }

  void removeCheque(String id, int chequeNo) {
    //Removes the chequeNo from the list
    state.firstWhere((cd) => cd.id == id).chequeNos.remove(chequeNo);
    //If chequeDeposit has no more cheques in its list, delete the chequeDeposit
    state.firstWhere((cd) => cd.id == id).chequeNos.isEmpty
        ? state.removeWhere((cd) => cd.id == id)
        : '';
    state = [...state];
  }

  void addChequeDeposit(ChequeDeposit chequeDeposit) {
    state = [...state, chequeDeposit];
    _repo.chequesDeposits = state;
  }

  void removeChequeDeposit(String chequeDepositId) {
    state.removeWhere((cd) => cd.id == chequeDepositId);
    _repo.chequesDeposits = state;
  }

  ChequeDeposit getChequesDeposit(String id) {
    return state.firstWhere((cd) => cd.id == id);
  }

  void updateStatus(String id, String status) {
    ChequeDeposit cd = state.firstWhere((cd) => cd.id == id);
    cd.status = status;
    state.firstWhere((cd) => cd.id == id).cashedDate =
        '${DateTime.now().day.toString()}-${DateTime.now().month.toString()}-${DateTime.now().year.toString()}';
    //By default set the cash date to current date
    _repo.chequesDeposits = state;
  }

  String getStatus(String id) {
    return state.firstWhere((cd) => cd.id == id).status;
  }
}

final chequeDepositNotifierProvider =
    NotifierProvider<ChequeDepositNotifier, List<ChequeDeposit>>(
        () => ChequeDepositNotifier());
