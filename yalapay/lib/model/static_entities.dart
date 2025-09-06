import 'package:floor/floor.dart';

@Entity(tableName: "bankaccounts")
class BankAccount {
  @PrimaryKey()
  String accountNo;
  String bank;

  BankAccount({required this.accountNo, required this.bank});

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(accountNo: json["accountNo"], bank: json["bank"]);
  }
}

@Entity(tableName: "banks")
class Bank {
  @PrimaryKey()
  String bankName;
  Bank({required this.bankName});
}

@Entity(tableName: "chequeStatus")
class ChequeStatus {
  @PrimaryKey()
  String chequeStatus;
  ChequeStatus({required this.chequeStatus});
}

@Entity(tableName: "depositStatus")
class DepositStatus {
  @PrimaryKey()
  String depositStatus;
  DepositStatus({required this.depositStatus});
}

@Entity(tableName: "invoiceStatus")
class InvoiceStatus {
  @PrimaryKey()
  String invoiceStatus;
  InvoiceStatus({required this.invoiceStatus});
}

@Entity(tableName: "paymentMode")
class PaymentMode {
  @PrimaryKey()
  String paymentMode;
  PaymentMode({required this.paymentMode});
}

@Entity(tableName: "returnReason")
class ReturnReason {
  @PrimaryKey()
  String returnReason;
  ReturnReason({required this.returnReason});
}
