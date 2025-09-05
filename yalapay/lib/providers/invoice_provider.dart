import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalapay/model/invoice.dart';
import 'package:yalapay/repositories/invoice_repository.dart';

class InvoiceNotifier extends Notifier<List<Invoice>> {
  final InvoiceRepository _repo = InvoiceRepository();
  List<Invoice> _allInvoices = [];

  @override
  List<Invoice> build() {
    initializeInvoices();
    return [];
  }

  void initializeInvoices() async {
    List<Invoice> invoices = await _repo.getInvoices();
    _allInvoices = invoices;
    state = invoices;
  }

  void filterByIdName(String value) {
    state = _allInvoices
        .where((invoice) =>
            invoice.customerName.toLowerCase().contains(value.toLowerCase()) ||
            invoice.id.contains(value))
        .toList();
  }

  void showAll() {
    state = _allInvoices;
  }

  void removeInvoice(String id) {
    state = state.where((invoice) => invoice.id != id).toList();
    _allInvoices = _allInvoices.where((invoice) => invoice.id != id).toList();
    _repo.invoices = state;
  }

  void addInvoice(Invoice invoice) {
    state = [...state, invoice];
    _allInvoices = [..._allInvoices, invoice];
    _repo.invoices = state;
  }

  List<Invoice> getInvoicesByCustId(String custId) =>
      state.where((invoice) => invoice.customerId == custId).toList();

  void updateInvoiceCust(String custId, String newCompanyName) {
    List<Invoice> invoicesOfCustomer = getInvoicesByCustId(custId);
    for (var invoice in invoicesOfCustomer) {
      removeInvoice(invoice.id);
      invoice.customerName = newCompanyName;
      addInvoice(invoice);
    }
  }

  void updateInvoiceDue(String newDateString, String id) {
    Invoice invoice = getInvoice(id);
    removeInvoice(id);
    invoice.dueDate = newDateString;
    addInvoice(invoice);
  }

  void filterByDate(String dateFrom, String dateTo) {
    DateTime _dateFrom;
    DateTime _dateTo;

    if (dateTo.isEmpty) {
      _dateFrom = DateTime.parse("2024-10-02");
    } else {
      try {
        _dateFrom = DateTime.parse(dateFrom);
      } catch (e) {
        _dateFrom = DateTime.parse("2024-10-02");
        const SnackBar(content: Text("Error"));
      }
    }

    if (dateTo.isEmpty) {
      _dateTo = DateTime.now();
    } else {
      try {
        _dateTo = DateTime.parse(dateTo);
      } catch (e) {
        _dateTo = DateTime.now();
        const SnackBar(content: Text("Error"));
      }
    }

    List<Invoice> updated = [];
    for (var invoice in _allInvoices) {
      DateTime invoiceDate = DateTime.parse(invoice.dueDate);
      if (invoiceDate.isBefore(_dateTo) || invoiceDate.isAfter(_dateFrom)) {
        updated.add(invoice);
      }
    }
    state = updated;
  }

  double getTotal() {
    if (state.isNotEmpty) {
      List<double> amounts = state.map((invoice) => invoice.amount).toList();
      return amounts.reduce((a, b) => a + b);
    } else {
      return 0;
    }
  }

  List<Invoice> filterByStatus(String status) {
    return state.where((invoice) => invoice.status == status).toList();
  }

  List<Invoice> getInvoiceList(){
    return _allInvoices;
  }

  Invoice getInvoice(String id) =>
      state.firstWhere((invoice) => invoice.id == id);

  void sortById() {
    _allInvoices.sort((a, b) => a.id.compareTo(b.id));
    state = List.from(_allInvoices);
  }
}

final invoiceNotifierProvider =
    NotifierProvider<InvoiceNotifier, List<Invoice>>(() => InvoiceNotifier());
