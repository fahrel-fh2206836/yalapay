class ChequeDeposit {
  String id;
  String depositDate;
  late String cashedDate; //For cheques deposit thats cashed
  String bankAccountNo;
  String status; //Deposited, Cashed, Cash with Returns,
  List<int> chequeNos; //List of selected cheques

  ChequeDeposit({
    required this.id,
    required this.depositDate,
    required this.bankAccountNo,
    required this.status,
    required this.chequeNos,
    this.cashedDate = '',
  });

  factory ChequeDeposit.fromJson(Map<String, dynamic> map) {
    return ChequeDeposit(
      id: map['id'] as String,
      depositDate: map['depositDate'] as String,
      bankAccountNo: map['bankAccountNo'] as String,
      status: map['status'] as String,
      chequeNos: List<int>.from(map['chequeNos']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'depositDate': depositDate,
      'bankAccountNo': bankAccountNo,
      'status': status,
      'chequeNos': chequeNos,
    };
  }
}
