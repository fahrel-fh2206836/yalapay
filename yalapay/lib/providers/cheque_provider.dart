import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalapay/constants/constants.dart';
import 'package:yalapay/model/cheque.dart';
import 'package:yalapay/providers/repo_provider.dart';
import 'package:yalapay/repositories/yalapay_repo.dart';

class ChequeNotifier extends AsyncNotifier<List<Cheque>> {
  late final YalapayRepo _repo;
  List<Cheque> allCheques = [];

  @override
  Future<List<Cheque>> build() async {
    _repo = await ref.watch(repoProvider.future);
    initializeCheques();
    return [];
  }

  Future<void> initializeCheques() async {
    _repo.observeCheque().listen((cheque) {
      state = AsyncData(cheque);
      allCheques = List.from(cheque);
    });
  }

  void showAll() => initializeCheques();

  Future<bool> checkIdDuplicate(int chequeNo) async =>
      await _repo.checkChequeIfDuplicate(chequeNo);

  Future<void> updateChequeDue(int chequeNo, String newDueDate) async {
    Cheque? cheque = await _repo.getCheque(chequeNo);
    cheque!.dueDate = newDueDate;
    _repo.updateCheque(cheque);
  }

  Future<void> updateChequeImage(int chequeNo, String newImageUri) async {
    Cheque? cheque = await _repo.getCheque(chequeNo);
    cheque!.chequeImageUri = newImageUri;
    _repo.updateCheque(cheque);
  }

  void addCheque(Cheque cheque) => _repo.addCheque(cheque);

  void removeCheque(int chequeNo) => _repo.removeCheque(chequeNo);

  Future<List<Cheque>> getChequesByNo(List<int> chequeNoList) =>
      _repo.getChequesByNo(chequeNoList);

  Future<Cheque?> getCheque(int chequeNo) async =>
      await _repo.getCheque(chequeNo);

  Future<void> updateNewlyDepositedCheques(
      {required int chequeNo,
      required String status,
      required String date}) async {
    Cheque? cheque = await getCheque(chequeNo);
    cheque!.status = status;
    cheque.depositDate = date;
    await _repo.updateCheque(cheque);
  }

  Future<void> updateChequeDate({
    required int chequeNo,
    required DateType dateType,
    required String date,
  }) async {
    Cheque? cheque = await getCheque(chequeNo);
    if (dateType == DateType.cashedDate) {
      cheque!.cashedDate = date;
    } else if (dateType == DateType.depositDate) {
      cheque!.depositDate = date;
    } else {
      cheque!.returnedDate = date;
    }
    await _repo.updateCheque(cheque);
  }

  Future<void> updateChequeListStatus(
      {required List<int> chequeNoList, required String status}) async {
    for (var chequeNo in chequeNoList) {
      Cheque? cheque = await getCheque(chequeNo);
      cheque!.status = status;
      await _repo.updateCheque(cheque);
    }
  }

  Future<void> updateChequeListDate(
      {required List<int> chequeNoList,
      required String date,
      required DateType type}) async {
    for (var chequeNo in chequeNoList) {
      await updateChequeDate(chequeNo: chequeNo, dateType: type, date: date);
    }
  }

  void setReturnInfo(
      {required List<int> chequeNoList, required String reason}) async {
    for (var chequeNo in chequeNoList) {
      Cheque? cheque = await getCheque(chequeNo);
      cheque!.returnReason = reason;
      await _repo.updateCheque(cheque);
    }
  }

  void updateCheque(Cheque cheque) => _repo.updateCheque(cheque);

  Future<double> getChequeTotalByStatus(String status) =>
      _repo.getChequeTotalByStatus(status);
}

final chequeNotifierProvider =
    AsyncNotifierProvider<ChequeNotifier, List<Cheque>>(() => ChequeNotifier());

//Cheque status provider
final chequeStatusProvider = FutureProvider<List<String>>((ref) async {
  final repository = await ref.watch(yalaPayStaticRepoProvider.future);
  final chequeStatuses = await repository.getChequeStatus();
  return chequeStatuses.map((status) => status.chequeStatus).toList();
});

//Return reasons provider
final returnReasonProvider = FutureProvider<List<String>>((ref) async {
  final repository = await ref.watch(yalaPayStaticRepoProvider.future);
  final returnReasons = await repository.getReturnReason();
  return returnReasons.map((reason) => reason.returnReason).toList();
});
