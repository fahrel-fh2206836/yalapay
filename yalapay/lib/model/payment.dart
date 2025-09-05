class Payment {
  String id;
  String invoiceNo;
  double amount;
  String paymentDate;
  String paymentMode;
  int chequeNo;

  Payment({
    required this.id,
    required this.invoiceNo,
    required this.amount,
    required this.paymentDate,
    required this.paymentMode,
    this.chequeNo = -1,
  });

  factory Payment.fromJson(Map<String, dynamic> map) {
    if (map
        case {
          "id": String id,
          "invoiceNo": String invoiceNo,
          "amount": double amount,
          "paymentDate": String paymentDate,
          "paymentMode": String paymentMode,
          "chequeNo": int chequeNo,
        }) {
      return Payment(
          id: id,
          invoiceNo: invoiceNo,
          amount: amount,
          paymentDate: paymentDate,
          paymentMode: paymentMode,
          chequeNo: chequeNo);
    }
    return Payment(
      id: map['id'],
      invoiceNo: map['invoiceNo'],
      amount: map['amount'],
      paymentDate: map['paymentDate'],
      paymentMode: map['paymentMode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNo': invoiceNo,
      'amount': amount,
      'paymentDate': paymentDate,
      'paymentMode': paymentMode,
      'chequeNo': chequeNo
    };
  }
}
