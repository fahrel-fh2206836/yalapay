import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalapay/model/address.dart';
import 'package:yalapay/model/contact_details.dart';
import 'package:yalapay/model/customer.dart';
import 'package:yalapay/repositories/customer_repository.dart';

class CustomerNotifier extends Notifier<List<Customer>> {
  final CustomerRepository _repo = CustomerRepository();
  List<Customer> _allCustomers = [];

  @override
  List<Customer> build() {
    if (_allCustomers.isEmpty) {
      initializeCustomers();
    }
    return _allCustomers;
  }

  Future<void> initializeCustomers() async {
    _allCustomers = await _repo.getCustomers();
    state = _allCustomers;
  }

  void filterByName(String name) {
    state = _allCustomers
        .where((customer) =>
            customer.companyName.toLowerCase().contains(name.toLowerCase()))
        .toList();
  }

  void showAll() {
    state = _allCustomers;
  }

  Customer getCustomer(String id) {
    return state.firstWhere((c) => c.id == id);
  }

  void updateCompanyName(String id, String newCompanyName) {
    Customer oldCustomer = state.firstWhere((c) => c.id == id);
    Customer newCustomer = Customer(
        id: id,
        companyName: newCompanyName,
        address: oldCustomer.address,
        contactDetails: oldCustomer.contactDetails);

    _replaceCustomer(oldCustomer.id, newCustomer);
  }

  void updateAddress(
      String id, String newStreet, String newCity, String newCountry) {
    Customer oldCustomer = state.firstWhere((c) => c.id == id);
    Address newAddress =
        Address(street: newStreet, city: newCity, country: newCountry);
    Customer newCustomer = Customer(
        id: id,
        companyName: oldCustomer.companyName,
        address: newAddress,
        contactDetails: oldCustomer.contactDetails);

    _replaceCustomer(oldCustomer.id, newCustomer);
  }

  void updateContactDetails(String id, String newFirstName, String newLastName,
      String newEmail, String newMobile) {
    Customer oldCustomer = state.firstWhere((c) => c.id == id);
    ContactDetails newContactDetails = ContactDetails(
        firstName: newFirstName,
        lastName: newLastName,
        email: newEmail,
        mobile: newMobile);
    Customer newCustomer = Customer(
        id: id,
        companyName: oldCustomer.companyName,
        address: oldCustomer.address,
        contactDetails: newContactDetails);

    _replaceCustomer(oldCustomer.id, newCustomer);
  }

  void _replaceCustomer(String id, Customer newCustomer) {
    removeCustomer(id);
    addCustomer(newCustomer);
  }

  void removeCustomer(String id) {
    state = state.where((customer) => customer.id != id).toList();
    _allCustomers =
        _allCustomers.where((customer) => customer.id != id).toList();
    _repo.customers = _allCustomers;
  }

  void addCustomer(Customer customer) {
    state = [...state, customer];
    _allCustomers = [..._allCustomers, customer];
    _repo.customers = _allCustomers;
  }

  bool isCustomerExistByName(String name) =>
      _allCustomers.any((customer) => customer.companyName == name);

  bool isCustomerExistById(String id) =>
      _allCustomers.any((customer) => customer.id == id);

  void sortById() {
    _allCustomers.sort((a, b) => a.id.compareTo(b.id));
    state = List.from(_allCustomers);
  }
}

final customerNotifierProvider =
    NotifierProvider<CustomerNotifier, List<Customer>>(
        () => CustomerNotifier());
