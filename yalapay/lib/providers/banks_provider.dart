import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalapay/model/static_entities.dart';
import 'package:yalapay/providers/repo_provider.dart';

final bankProvider = FutureProvider<List<String>>((ref) async {
  final repository = await ref.watch(yalaPayStaticRepoProvider.future);
  final banks = await repository.getBank();
  return banks.map((bank) => bank.bankName).toList();
});

final bankAccountMapProvider = FutureProvider<List<BankAccount>>((ref) async {
  final repository = await ref.watch(yalaPayStaticRepoProvider.future);
  return repository.getBankAccounts();
});
