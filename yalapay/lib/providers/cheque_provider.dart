import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalapay/constants/constants.dart';
import 'package:yalapay/model/cheque.dart';
import 'package:yalapay/repositories/cheque_repository.dart';

class ChequeNotifier extends Notifier<List<Cheque>> {
  final ChequeRepository _repo = ChequeRepository();
  List<Cheque> _allCheques = [];
  @override
  List<Cheque> build() {
    initializeCheques();
    return [];
  }

  void initializeCheques() async {
    List<Cheque> cheques = await _repo.getCheques();
    _allCheques = cheques;
    state = cheques;
  }

  void showAll() {
    state = _allCheques;
  }

  bool checkIdDuplicate(int chequeNo) {
    return _repo.cheques
        .where((cheque) => cheque.chequeNo == chequeNo)
        .toList()
        .isNotEmpty;
  }

  void updateChequeDue(int chequeNo, String newDueDate) {
    Cheque? cheque = state.firstWhere((c) => c.chequeNo == chequeNo);
    cheque.dueDate = newDueDate;
  }

  void updateChequeImage(int chequeNo, String newImageUri) {
    Cheque? cheque = state.firstWhere((c) => c.chequeNo == chequeNo);
    cheque.chequeImageUri = newImageUri;
  }

  void addCheque(Cheque cheque) {
    state = [...state, cheque];
    _allCheques = [..._allCheques, cheque];
    _repo.cheques = state;
  }

  void removeCheque(int chequeNo) {
    state.removeWhere((cheque) => cheque.chequeNo == chequeNo);
    _allCheques.removeWhere((cheque) => cheque.chequeNo == chequeNo);
    _repo.cheques = state;
  }

  void setByStatus(String status) {
    state = state.where((cheque) => cheque.status == status).toList();
  }

  List<Cheque> getChequesByNo(List<int> chequeNoList) {
    List<Cheque> chequeList = [];
    for (var chequeNo in chequeNoList) {
      chequeList.add(state.firstWhere((c) => c.chequeNo == chequeNo));
    }
    return chequeList;
  }

  Cheque getCheque(int chequeNo) {
    return state.firstWhere((cheque) => cheque.chequeNo == chequeNo);
  }

  void updateNewlyDepositedCheques(
      {required int chequeNo, required String status, required String date}) {
    Cheque cheque = getCheque(chequeNo);
    cheque.status = status;
    cheque.depositDate = date;
  }

  void updateChequeDate({
    required int chequeNo,
    required DateType dateType,
    required String date,
  }) {
    Cheque cheque = getCheque(chequeNo);
    if (dateType == DateType.cashedDate) {
      cheque.cashedDate = date;
    } else if (dateType == DateType.depositDate) {
      cheque.depositDate = date;
    } else {
      cheque.returnedDate = date;
    }
  }

  void updateChequeListStatus(
      {required List<int> chequeNoList, required String status}) {
    for (var chequeNo in chequeNoList) {
      state.firstWhere((c) => c.chequeNo == chequeNo).status = status;
    }
  }

  void updateChequeListDate(
      {required List<int> chequeNoList,
      required String date,
      required DateType type}) {
    for (var chequeNo in chequeNoList) {
      updateChequeDate(chequeNo: chequeNo, dateType: type, date: date);
    }
  }

  void setReturnInfo(
      {required List<int> chequeNoList, required String reason}) {
    for (var chequeNo in chequeNoList) {
      Cheque cheque = getCheque(chequeNo);
      cheque.returnReason = reason;
    }
  }
}

final chequeNotifierProvider =
    NotifierProvider<ChequeNotifier, List<Cheque>>(() => ChequeNotifier());
