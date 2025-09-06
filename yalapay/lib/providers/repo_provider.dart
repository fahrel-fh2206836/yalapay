import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalapay/repositories/yalapay_repo.dart';
import 'package:yalapay/repositories/yalapay_static_repo.dart';

import '../database/app_database.dart';

//Repo provider for firebase
final repoProvider = FutureProvider<YalapayRepo>((ref) async {
  final db = FirebaseFirestore.instance;
  final customerRef = db.collection('customers');
  final invoiceRef = db.collection('invoices');
  final paymentsRef = db.collection('payments');
  final chequeRef = db.collection('cheques');
  final chequeDepositRef = db.collection('chequeDeposits');
  return YalapayRepo(
      customerRef: customerRef,
      invoiceRef: invoiceRef,
      paymentsRef: paymentsRef,
      chequeRef: chequeRef,
      chequeDepositRef: chequeDepositRef);
});

final yalaPayStaticRepoProvider =
    FutureProvider<YalaPayStaticRepo>((ref) async {
  final database =
      await $FloorAppDatabase.databaseBuilder('app_database.db').build();

  return YalaPayStaticRepo(
      bankAccountsDao: database.bankAccountDao,
      bankDao: database.bankDao,
      chequeStatusDao: database.chequeStatusDao,
      depositStatusDao: database.depositStatusDao,
      invoiceStatusDao: database.invoiceStatusDao,
      paymentModeDao: database.paymentModeDao,
      returnReasonDao: database.returnReasonDao);
});
