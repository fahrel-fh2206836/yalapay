import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalapay/repositories/bank_repository.dart';

final bankProvider = FutureProvider<List<String>>((ref) async {
  final repository = BankRepository();
  return await repository.getBanks();
});
