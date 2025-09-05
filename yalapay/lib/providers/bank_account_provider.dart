import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalapay/repositories/bank_account_repository.dart';

final bankAccountMapProvider = FutureProvider<List<dynamic>>((ref) async {
  final repository = BankAccountRepository();
  return await repository.getMap();
});
