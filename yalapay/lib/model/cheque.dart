class Cheque {
  int chequeNo;
  double amount;
  String drawer;
  String bankName;
  String status;
  String receivedDate;
  String dueDate;
  String chequeImageUri;
  late String depositDate; //For cheques that will be deposited
  late String cashedDate; //For cheques that will be deposited
  late String returnedDate; //For returned cheques
  late String returnReason; //For returned cheques

  Cheque(
      {required this.chequeNo,
      required this.amount,
      required this.drawer,
      required this.bankName,
      required this.status,
      required this.receivedDate,
      required this.dueDate,
      required this.chequeImageUri,
      this.depositDate = '',
      this.cashedDate = '',
      this.returnedDate = '',
      this.returnReason = ''});

  String getStatus() => status;

  factory Cheque.fromJson(Map<String, dynamic> map) {
    return Cheque(
        chequeNo: map['chequeNo'],
        amount: map['amount'],
        drawer: map['drawer'],
        bankName: map['bankName'],
        status: map['status'],
        receivedDate: map['receivedDate'],
        dueDate: map['dueDate'],
        chequeImageUri: map['chequeImageUri']);
  }

  factory Cheque.fromJson2(Map<String, dynamic> map) {
    return Cheque(
      chequeNo: map['chequeNo'],
      amount: map['amount'],
      drawer: map['drawer'],
      bankName: map['bankName'],
      status: map['status'],
      receivedDate: map['receivedDate'],
      dueDate: map['dueDate'],
      chequeImageUri: map['chequeImageUri'],
      depositDate: map['depositDate'],
      cashedDate: map['cashedDate'],
      returnedDate: map['returnedDate'],
      returnReason: map['returnReason'],
    );
  }

  Map<String, dynamic> toJson() => {
        'chequeNo': chequeNo,
        'amount': amount,
        'drawer': drawer,
        'bankName': bankName,
        'status': status,
        'receivedDate': receivedDate,
        'dueDate': dueDate,
        'chequeImageUri': chequeImageUri,
        'depositDate': depositDate,
        'cashedDate': cashedDate,
        'returnedDate': returnedDate,
        'returnReason': returnReason,
      };
}
