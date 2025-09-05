import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalapay/repositories/cheque_status_repository.dart';

final chequeStatusProvider = FutureProvider<List<String>>((ref) async {
  final repository = ChequeStatusRepository();
  return await repository.fetchChequeStatuses();
});
