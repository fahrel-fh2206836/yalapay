import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalapay/repositories/invoice_status_repository.dart';

final invoiceStatusProvider = FutureProvider<List<String>>((ref) async {
  final repository = InvoiceStatusRepository();
  return await repository.fetchInvoiceStatuses();
});
