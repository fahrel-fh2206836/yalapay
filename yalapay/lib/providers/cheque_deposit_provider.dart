import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalapay/model/cheque_deposit.dart';
import 'package:yalapay/providers/repo_provider.dart';
import 'package:yalapay/repositories/yalapay_repo.dart';

class ChequeDepositNotifier extends AsyncNotifier<List<ChequeDeposit>> {
  late final YalapayRepo _repo;
  @override
  Future<List<ChequeDeposit>> build() async {
    _repo = await ref.watch(repoProvider.future);
    initializeChequeDeposit();
    return [];
  }

  Future<void> initializeChequeDeposit() async {
    _repo.observeChequeDeposits().listen((deposits) {
      state = AsyncData(deposits);
    });
  }

  Future<List<int>> getChequesNoList(String chequeDepositId) async {
    ChequeDeposit? deposit = await getChequesDeposit(chequeDepositId);
    return deposit!.chequeNos;
  }

  void removeCheque(String id, int chequeNo) async {
    ChequeDeposit? deposit = await getChequesDeposit(id);
    //Removes the chequeNo from the list
    deposit!.chequeNos.remove(chequeNo);
    //If chequeDeposit has no more cheques in its list, delete the chequeDeposit
    deposit.chequeNos.isEmpty
        ? _repo.deleteChequeDeposit(deposit)
        : _repo.updateChequeDeposit(deposit);
  }

  void addChequeDeposit(ChequeDeposit chequeDeposit) =>
      _repo.addChequeDeposit(chequeDeposit);

  Future<void> removeChequeDeposit(String chequeDepositId) async {
    ChequeDeposit? deposit = await getChequesDeposit(chequeDepositId);
    _repo.deleteChequeDeposit(deposit!);
  }

  Future<ChequeDeposit?> getChequesDeposit(String id) =>
      _repo.getChequeDepositById(id);

  void updateStatus(String id, String status) async {
    ChequeDeposit? deposit = await getChequesDeposit(id);
    deposit?.status = status;
    deposit?.cashedDate =
        '${DateTime.now().day.toString()}-${DateTime.now().month.toString()}-${DateTime.now().year.toString()}';
    //By default set the cash date to current date
    _repo.updateChequeDeposit(deposit!);
  }

  Future<String> getStatus(String id) async {
    ChequeDeposit? deposit = await getChequesDeposit(id);
    return deposit!.status;
  }
}

final chequeDepositNotifierProvider =
    AsyncNotifierProvider<ChequeDepositNotifier, List<ChequeDeposit>>(
        () => ChequeDepositNotifier());

//Deposit stauts provider
final depositStatusProvider = FutureProvider<List<String>>((ref) async {
  final repository = await ref.watch(yalaPayStaticRepoProvider.future);
  final depositStatuses = await repository.getDepositStatus();
  return depositStatuses.map((status) => status.depositStatus).toList();
});
