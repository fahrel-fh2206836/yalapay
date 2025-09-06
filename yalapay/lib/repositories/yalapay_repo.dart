import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:yalapay/model/cheque.dart';
import 'package:yalapay/model/cheque_deposit.dart';
import 'package:yalapay/model/customer.dart';
import 'package:yalapay/model/invoice.dart';
import 'package:yalapay/model/payment.dart';

class YalapayRepo {
  final CollectionReference customerRef;
  final CollectionReference invoiceRef;
  final CollectionReference paymentsRef;
  final CollectionReference chequeRef;
  final CollectionReference chequeDepositRef;

  YalapayRepo({
    required this.customerRef,
    required this.invoiceRef,
    required this.paymentsRef,
    required this.chequeRef,
    required this.chequeDepositRef,
  });

  // (*) Customer Repository ===================================================================

  //Initiazlizes from json if database is empty
  void initializeDatabase() async {
    final QuerySnapshot snapshotCustomer = await customerRef.get();
    final QuerySnapshot snapshotInvoice = await invoiceRef.get();
    final QuerySnapshot snapshotPayment = await paymentsRef.get();
    final QuerySnapshot snapshotCheque = await chequeRef.get();
    final QuerySnapshot snapshotDeposit = await chequeDepositRef.get();

    bool isCustomerCollectionEmpty = snapshotCustomer.docs.isEmpty;
    bool isInvoiceCollectionEmpty = snapshotInvoice.docs.isEmpty;
    bool isPaymentCollectionEmpty = snapshotPayment.docs.isEmpty;
    bool isChequeCollectionEmpty = snapshotCheque.docs.isEmpty;
    bool isChequeDepositCollectionEmpty = snapshotDeposit.docs.isEmpty;

    if (isCustomerCollectionEmpty &&
        isInvoiceCollectionEmpty &&
        isPaymentCollectionEmpty &&
        isChequeDepositCollectionEmpty &&
        isChequeCollectionEmpty) {
      String customerData =
          await rootBundle.loadString('assets/data/customers.json');
      var customersMap = jsonDecode(customerData);
      for (var customerMap in customersMap) {
        addCustomer(Customer.fromJson(customerMap));
      }

      List<Invoice> invoicesTemp = [];

      String invoiceData =
          await rootBundle.loadString('assets/data/invoices.json');
      var invoicesMap = jsonDecode(invoiceData);
      for (var invoiceMap in invoicesMap) {
        invoicesTemp.add(Invoice.fromJson(invoiceMap));
      }

      List<Payment> paymentsTemp = [];

      String paymentdata =
          await rootBundle.loadString('assets/data/payments.json');
      var paymentsMap = jsonDecode(paymentdata);
      for (var paymentMap in paymentsMap) {
        Payment payment = Payment.fromJson(paymentMap);
        paymentsTemp.add(payment);
        addPayment(payment);
      }

      List<Cheque> chequesTemp = [];

      String chequedata =
          await rootBundle.loadString('assets/data/cheques.json');
      var chequesMap = jsonDecode(chequedata);
      for (var chequeMap in chequesMap) {
        Cheque cheque = Cheque.fromJson(chequeMap);
        chequesTemp.add(cheque);
        addCheque(cheque);
      }

      for (var invoice in invoicesTemp) {
        List<Payment> invoicePayments = paymentsTemp
            .where((payment) => payment.invoiceNo == invoice.id)
            .toList();
        invoice.addAllPayments(invoicePayments);
        invoice.updateInvoiceBalance(chequesTemp);
        invoice.updateStatus();
        addInvoice(invoice);
      }

      String depositData =
          await rootBundle.loadString('assets/data/cheque-deposits.json');
      var depositsMap = jsonDecode(depositData);
      for (var depositMap in depositsMap) {
        ChequeDeposit deposit = ChequeDeposit.fromJson(depositMap);
        addChequeDeposit(deposit);
        for (var cheque in chequesTemp) {
          if (deposit.chequeNos.contains(cheque.chequeNo)) {
            cheque.depositDate = deposit.depositDate;
            updateCheque(cheque);
          }
        }
      }
    }
  }

  Stream<List<Customer>> observeCustomer() {
    initializeDatabase();
    return customerRef.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Customer.fromJson(doc.data() as Map<String, dynamic>))
        .toList());
  }

  Stream<List<Customer>> filterCustomer(String companyName) => customerRef
      .where("companyName",
          isGreaterThanOrEqualTo: companyName, isLessThan: '${companyName}z')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Customer.fromJson(doc.data() as Map<String, dynamic>))
          .toList());

  Stream<List<Customer>> sortCustomerById() =>
      customerRef.orderBy('id').snapshots().map((snapshot) => snapshot.docs
          .map((doc) => Customer.fromJson(doc.data() as Map<String, dynamic>))
          .toList());

  Future<Customer?> getCustomerById(String id) =>
      customerRef.doc(id).get().then((snapshot) =>
          Customer.fromJson(snapshot.data() as Map<String, dynamic>));

  Future<void> updateCustomer(Customer customer) =>
      customerRef.doc(customer.id).update(customer.toJson());

  Future<void> addCustomer(Customer customer) async {
    if (customer.id == '-1') {
      final docId = customerRef.doc().id;
      customer.id = docId;
    }
    await customerRef.doc(customer.id).set(customer.toJson());
  }

  Future<void> deleteCustomer(String id) async {
    await customerRef.where("id", isEqualTo: id).get().then((snapshot) =>
        snapshot.docs.forEach((doc) => customerRef.doc(doc.id).delete()));
  }

  Future<bool> isCustomerExistByName(String name) async {
    try {
      var query = await customerRef.where("name", isEqualTo: name).get();
      return query.docs.isNotEmpty; //Return true if document(customer) exist
    } catch (e) {
      print('Error checking customer existence: $e');
      return false; // Return false in case of an error
    }
  }

  // (*) Invoices Repository ===================================================================

  Stream<List<Invoice>> observeInvoices() {
    return invoiceRef.snapshots().map((snaphsot) => snaphsot.docs
        .map((doc) => Invoice.fromJson2(doc.data() as Map<String, dynamic>))
        .toList());
  }

  Stream<Invoice?> observeInvoiceById(String id) {
    return invoiceRef.where('id', isEqualTo: id).snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => Invoice.fromJson2(doc.data() as Map<String, dynamic>))
            .first);
  }

  Future<void> addInvoice(Invoice invoice) async {
    if (invoice.id == '-1') {
      final docId = invoiceRef.doc().id;
      invoice.id = docId;
    }
    await invoiceRef.doc(invoice.id).set(invoice.toJson());
  }

  Future<void> deleteInvoice(String id) => invoiceRef.doc(id).delete();

  Future<void> updateInvoice(Invoice invoice) =>
      invoiceRef.doc(invoice.id).update(invoice.toJson());

  Future<Invoice?> getInvoiceById(String id) => invoiceRef.doc(id).get().then(
      (snapshot) => Invoice.fromJson2(snapshot.data() as Map<String, dynamic>));

  Stream<List<Invoice>> filterInvoiceByStatus(String status) => invoiceRef
      .where("status", isEqualTo: status)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Invoice.fromJson2(doc.data() as Map<String, dynamic>))
          .toList());

  Stream<List<Invoice>> filterInvoiceByDate(
          DateTime fromDate, DateTime toDate) =>
      invoiceRef
          .where("dueDate", isGreaterThanOrEqualTo: fromDate)
          .where("dueDate", isLessThanOrEqualTo: toDate)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) =>
                  Invoice.fromJson2(doc.data() as Map<String, dynamic>))
              .toList());

  Stream<List<Invoice>> filterInvoiceById(String value) => invoiceRef
      .where("id", isGreaterThanOrEqualTo: value, isLessThan: '${value}z')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Invoice.fromJson2(doc.data() as Map<String, dynamic>))
          .toList());

  Stream<List<Invoice>> sortInvoicesById() =>
      invoiceRef.orderBy('id').snapshots().map((snapshot) => snapshot.docs
          .map((doc) => Invoice.fromJson2(doc.data() as Map<String, dynamic>))
          .toList());

  Future<List<Invoice>> getInvoicesByCustId(String custId) async {
    QuerySnapshot querySnapshot = await invoiceRef.get();
    return querySnapshot.docs
        .map((doc) => Invoice.fromJson2(doc.data() as Map<String, dynamic>))
        .toList()
        .where((invoice) => invoice.customerId == custId)
        .toList();
  }

  Future<double> getTotalAmountOfInvoices() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('invoices').get();

      double totalAmount = querySnapshot.docs.fold(0.0, (sum, doc) {
        double amount = doc.data()['amount'] ?? 0.0;
        return sum + amount;
      });

      return totalAmount;
    } catch (e) {
      print('Error calculating total amount: $e');
      return 0.0;
    }
  }

  // (*) Payments Repository ===================================================================
  Stream<List<Payment>> observePayments() {
    return paymentsRef.snapshots().map((snaphsot) => snaphsot.docs
        .map((doc) => Payment.fromJson(doc.data() as Map<String, dynamic>))
        .toList());
  }

  void addPayment(Payment payment) async {
    if (payment.id == '-1') {
      final docId = paymentsRef.doc().id;
      payment.id = docId;
    }
    await paymentsRef.doc(payment.id).set(payment.toJson());
  }

  Future<void> removePayment(String id) => paymentsRef.doc(id).delete();

  Stream<List<Payment>> filterPaymentByAmount(
          double amount, String invoiceId) =>
      paymentsRef
          .where("amount", isGreaterThanOrEqualTo: amount)
          .where('invoiceNo', isEqualTo: invoiceId)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map(
                  (doc) => Payment.fromJson(doc.data() as Map<String, dynamic>))
              .toList());

  Stream<List<Payment>> filterPaymentByDate(DateTime date, String invoiceId) =>
      paymentsRef
          .where("paymentDate", isGreaterThanOrEqualTo: date)
          .where('invoiceNo', isEqualTo: invoiceId)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map(
                  (doc) => Payment.fromJson(doc.data() as Map<String, dynamic>))
              .toList());

  Stream<List<Payment>> filterPaymentByMode(String mode, String invoiceId) =>
      paymentsRef
          .where("paymentMode", isEqualTo: mode)
          .where('invoiceNo', isEqualTo: invoiceId)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map(
                  (doc) => Payment.fromJson(doc.data() as Map<String, dynamic>))
              .toList());

  Stream<List<Payment>> getPaymentsByInvoiceId(String id) => paymentsRef
      .where("invoiceNo", isEqualTo: id)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Payment.fromJson(doc.data() as Map<String, dynamic>))
          .toList());

  Future<Payment?> getPaymentWithChequeNo(int chequeNo) async {
    QuerySnapshot querySnapshot = await paymentsRef.get();
    return querySnapshot.docs
        .map((doc) => Payment.fromJson(doc.data() as Map<String, dynamic>))
        .toList()
        .where((payment) => payment.chequeNo == chequeNo)
        .first;
  }

  // (*) Cheques Repository ===================================================================

  Stream<List<Cheque>> observeCheque() {
    return chequeRef.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Cheque.fromJson2(doc.data() as Map<String, dynamic>))
        .toList());
  }

  Future<void> addCheque(Cheque cheque) async {
    chequeRef.doc(cheque.chequeNo.toString()).set(cheque.toJson());
  }

  Future<Cheque?> getCheque(int chequeNo) {
    return chequeRef.doc(chequeNo.toString()).get().then((snapshot) =>
        Cheque.fromJson2(snapshot.data() as Map<String, dynamic>));
  }

  Future<void> removeCheque(int chequeNo) async {
    await chequeRef.doc(chequeNo.toString()).delete();
  }

  //One update method is enough, just need to pass the modified cheque from the provider
  Future<void> updateCheque(Cheque cheque) =>
      chequeRef.doc(cheque.chequeNo.toString()).update(cheque.toJson());

  Future<bool> checkChequeIfDuplicate(int chequeNo) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('payments')
              .where('chequeNo', isEqualTo: chequeNo)
              .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking duplicates: $e');
      return false;
    }
  }

  Future<List<Cheque>> getChequesByNo(List<int> chequeNoList) async {
    QuerySnapshot querySnapshot = await chequeRef.get();
    return querySnapshot.docs
        .map((doc) => Cheque.fromJson2(doc.data() as Map<String, dynamic>))
        .toList()
        .where((cheque) => chequeNoList.contains(cheque.chequeNo))
        .toList();
  }

  Future<double> getChequeTotalByStatus(String status) async {
    double totalAmount = 0;
    QuerySnapshot querySnapshot = await chequeRef.get();
    List<Cheque> chequeListByStatus = querySnapshot.docs
        .map((doc) => Cheque.fromJson2(doc.data() as Map<String, dynamic>))
        .toList()
        .where((cheque) => cheque.status == status)
        .toList();
    if (chequeListByStatus.isNotEmpty) {
      totalAmount = chequeListByStatus
          .map((cheque) => cheque.amount)
          .reduce((a, b) => a + b);
    }

    return totalAmount;
  }

  // (*) Cheque Deposit Repository ===================================================================

  Stream<List<ChequeDeposit>> observeChequeDeposits() {
    return chequeDepositRef.snapshots().map((snapshot) => snapshot.docs
        .map((doc) =>
            ChequeDeposit.fromJson2(doc.data() as Map<String, dynamic>))
        .toList());
  }

  Future<void> addChequeDeposit(ChequeDeposit deposit) async {
    if (deposit.id == '-1') {
      final docId = chequeDepositRef.doc().id;
      deposit.id = docId;
    }
    await chequeDepositRef.doc(deposit.id).set(deposit.toJson());
  }

  Future<void> deleteChequeDeposit(ChequeDeposit deposit) =>
      chequeDepositRef.doc(deposit.id).delete();

  Future<void> updateChequeDeposit(ChequeDeposit deposit) =>
      chequeDepositRef.doc(deposit.id).update(deposit.toJson());

  Future<ChequeDeposit?> getChequeDepositById(String id) =>
      chequeDepositRef.doc(id).get().then((snapshot) =>
          ChequeDeposit.fromJson2(snapshot.data() as Map<String, dynamic>));
}
