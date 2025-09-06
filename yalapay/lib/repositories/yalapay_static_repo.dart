import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:yalapay/database/static_dao.dart';

import '../model/static_entities.dart';

class YalaPayStaticRepo {
  final BankAccountsDao bankAccountsDao;
  final BankDao bankDao;
  final ChequeStatusDao chequeStatusDao;
  final DepositStatusDao depositStatusDao;
  final InvoiceStatusDao invoiceStatusDao;
  final PaymentModeDao paymentModeDao;
  final ReturnReasonDao returnReasonDao;

  YalaPayStaticRepo(
      {required this.bankAccountsDao,
      required this.bankDao,
      required this.chequeStatusDao,
      required this.depositStatusDao,
      required this.invoiceStatusDao,
      required this.paymentModeDao,
      required this.returnReasonDao});

  Future<List<BankAccount>> getBankAccounts() async {
    bool isBankAccountTableEmpty =
        await bankAccountsDao.getBankAccountCount() == 0;
    if (isBankAccountTableEmpty) {
      final String response =
          await rootBundle.loadString('assets/data/bank-accounts.json');
      final data = json.decode(response);
      for (var bankAccountMap in data) {
        bankAccountsDao.addBankAccount(BankAccount.fromJson(bankAccountMap));
      }
    }

    return bankAccountsDao.getBankAccounts();
  }

  Future<List<Bank>> getBank() async {
    bool isBankTableEmpty = await bankDao.getBankCount() == 0;
    if (isBankTableEmpty) {
      final String response =
          await rootBundle.loadString('assets/data/banks.json');
      final List<dynamic> data = json.decode(response);
      final List<String> stringData = List<String>.from(data);
      for (var bankName in stringData) {
        bankDao.addBank(Bank(bankName: bankName));
      }
    }

    return bankDao.getBank();
  }

  Future<List<ChequeStatus>> getChequeStatus() async {
    bool isChequeStatusTableEmpty =
        await chequeStatusDao.getChequeStatusCount() == 0;
    if (isChequeStatusTableEmpty) {
      final String response =
          await rootBundle.loadString('assets/data/cheque-status.json');
      final List<dynamic> data = json.decode(response);
      final List<String> stringData = List<String>.from(data);
      for (var status in stringData) {
        chequeStatusDao.addChequeStatus(ChequeStatus(chequeStatus: status));
      }
    }

    return chequeStatusDao.getChequeStatus();
  }

  Future<List<DepositStatus>> getDepositStatus() async {
    bool isDepositStatusTableEmpty =
        await depositStatusDao.getDepositStatusCount() == 0;
    if (isDepositStatusTableEmpty) {
      String response =
          await rootBundle.loadString("assets/data/deposit-status.json");
      final List<dynamic> data = jsonDecode(response);
      final List<String> stringData = List<String>.from(data);
      for (var status in stringData) {
        depositStatusDao.addDepositStatus(DepositStatus(depositStatus: status));
      }
    }

    return depositStatusDao.getDepositStatus();
  }

  Future<List<InvoiceStatus>> getInvoiceStatus() async {
    bool isInvoiceStatusTableEmpty =
        await invoiceStatusDao.getInvoiceStatusCount() == 0;
    if (isInvoiceStatusTableEmpty) {
      final String response =
          await rootBundle.loadString('assets/data/invoice-status.json');
      final List<dynamic> data = json.decode(response);
      final List<String> stringData = List<String>.from(data);
      for (var status in stringData) {
        invoiceStatusDao.addInvoiceStatus(InvoiceStatus(invoiceStatus: status));
      }
    }

    return invoiceStatusDao.getInvoiceStatus();
  }

  Future<List<PaymentMode>> getPaymentMode() async {
    bool isPaymentModeTableEmpty = await paymentModeDao.getModesCount() == 0;
    if (isPaymentModeTableEmpty) {
      final String response =
          await rootBundle.loadString('assets/data/payment-modes.json');
      final List<dynamic> data = json.decode(response);
      final List<String> stringData = List<String>.from(data);
      for (var mode in stringData) {
        paymentModeDao.addPaymentMode(PaymentMode(paymentMode: mode));
      }
    }

    return paymentModeDao.getPaymentMode();
  }

  Future<List<ReturnReason>> getReturnReason() async {
    bool isReturnReasonTableEmpty =
        await returnReasonDao.getReasonsCount() == 0;
    if (isReturnReasonTableEmpty) {
      final String response =
          await rootBundle.loadString('assets/data/return-reasons.json');
      final List<dynamic> data = json.decode(response);
      final List<String> stringData = List<String>.from(data);
      for (var reason in stringData) {
        returnReasonDao.addReturnReason(ReturnReason(returnReason: reason));
      }
    }

    return returnReasonDao.getReturnReason();
  }
}
