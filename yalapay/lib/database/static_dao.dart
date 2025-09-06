import 'package:floor/floor.dart';
import 'package:yalapay/model/static_entities.dart';

@dao
abstract class BankAccountsDao {
  @Query("SELECT * FROM bankaccounts")
  Future<List<BankAccount>> getBankAccounts();

  @Query("SELECT COUNT(*) FROM bankaccounts")
  Future<int?> getBankAccountCount();

  @insert
  Future<void> addBankAccount(BankAccount bankAccount);
}

@dao
abstract class BankDao {
  @Query("SELECT * FROM banks")
  Future<List<Bank>> getBank();

  @Query("SELECT COUNT(*) FROM banks")
  Future<int?> getBankCount();

  @insert
  Future<void> addBank(Bank bank);
}

@dao
abstract class ChequeStatusDao {
  @Query("SELECT * FROM chequeStatus")
  Future<List<ChequeStatus>> getChequeStatus();

  @Query("SELECT COUNT(*) FROM chequeStatus")
  Future<int?> getChequeStatusCount();

  @insert
  Future<void> addChequeStatus(ChequeStatus chequeStatus);
}

@dao
abstract class DepositStatusDao {
  @Query("SELECT * FROM depositStatus")
  Future<List<DepositStatus>> getDepositStatus();

  @Query("SELECT COUNT(*) FROM depositStatus")
  Future<int?> getDepositStatusCount();

  @insert
  Future<void> addDepositStatus(DepositStatus depositStatus);
}

@dao
abstract class InvoiceStatusDao {
  @Query("SELECT * FROM invoiceStatus")
  Future<List<InvoiceStatus>> getInvoiceStatus();

  @Query("SELECT COUNT(*) FROM invoiceStatus")
  Future<int?> getInvoiceStatusCount();

  @insert
  Future<void> addInvoiceStatus(InvoiceStatus invoiceStatus);
}

@dao
abstract class PaymentModeDao {
  @Query("SELECT * FROM paymentMode")
  Future<List<PaymentMode>> getPaymentMode();

  @Query("SELECT COUNT(*) FROM paymentMode")
  Future<int?> getModesCount();

  @insert
  Future<void> addPaymentMode(PaymentMode paymentMode);
}

@dao
abstract class ReturnReasonDao {
  @Query("SELECT * FROM returnReason")
  Future<List<ReturnReason>> getReturnReason();

  @Query("SELECT COUNT(*) FROM returnReason")
  Future<int?> getReasonsCount();

  @insert
  Future<void> addReturnReason(ReturnReason returnReason);
}
