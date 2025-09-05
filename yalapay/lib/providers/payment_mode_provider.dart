import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalapay/repositories/payment_mode_repository.dart';

final paymentModeProvider = FutureProvider<List<String>>((ref) async {
  final repository = PaymentModeRepository();
  return await repository.getPaymentModes();
});
