import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalapay/repositories/deposit_status_repository.dart';

final depositStatusProvider = FutureProvider<List<String>>((ref) async {
  final repository = DepositStatusRepository();
  return repository.getDepositStatus();
});
