import 'dart:async';

import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:yalapay/database/static_dao.dart';
import 'package:yalapay/model/static_entities.dart';

part 'app_database.g.dart';

@Database(version: 1, entities: [
  BankAccount,
  Bank,
  ChequeStatus,
  DepositStatus,
  InvoiceStatus,
  PaymentMode,
  ReturnReason
])
abstract class AppDatabase extends FloorDatabase {
  BankAccountsDao get bankAccountDao;
  BankDao get bankDao;
  ChequeStatusDao get chequeStatusDao;
  DepositStatusDao get depositStatusDao;
  InvoiceStatusDao get invoiceStatusDao;
  PaymentModeDao get paymentModeDao;
  ReturnReasonDao get returnReasonDao;
}
