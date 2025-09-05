import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalapay/repositories/return_reason_repository.dart';

final returnReasonProvider = FutureProvider<List<String>>((ref) async {
  final repository = ReturnReasonRepository();
  return await repository.fetchReturnReasons();
});