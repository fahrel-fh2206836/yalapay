import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalapay/model/address.dart';
import 'package:yalapay/model/contact_details.dart';
import 'package:yalapay/model/customer.dart';
import 'package:yalapay/providers/repo_provider.dart';
import 'package:yalapay/repositories/yalapay_repo.dart';

class CustomerNotifier extends AsyncNotifier<List<Customer>> {
  late final YalapayRepo _repo;
  // List<Customer> _allCustomers = [];

  @override
  Future<List<Customer>> build() async {
    _repo = await ref.watch(repoProvider.future);
    initializeCustomers();
    return [];
  }

  Future<void> initializeCustomers() async {
    _repo.observeCustomer().listen((customer) {
      state = AsyncData(customer);
      // _allCustomers = List.from(customer);
    }).onError((error) {
      print(error);
    });
  }

  void filterByName(String name) {
    _repo.filterCustomer(name).listen((customer) {
      state = AsyncData(customer);
    }).onError((error) {
      print(error);
    });
  }

  void showAll() => initializeCustomers();

  Future<Customer?> getCustomer(String id) => _repo.getCustomerById(id);

  void updateCompany(
      {required String id,
      required String newCompanyName,
      required String newStreet,
      required String newCity,
      required String newCountry,
      required String newFirstName,
      required String newLastName,
      required String newEmail,
      required String newMobile}) async {
    ContactDetails newContactDetails = ContactDetails(
        firstName: newFirstName,
        lastName: newLastName,
        email: newEmail,
        mobile: newMobile);
    Address newAddress =
        Address(street: newStreet, city: newCity, country: newCountry);
    Customer updatedCustomer = Customer(
        id: id,
        companyName: newCompanyName,
        address: newAddress,
        contactDetails: newContactDetails);
    _repo.updateCustomer(updatedCustomer);
  }

  void removeCustomer(String id) {
    _repo.deleteCustomer(id);
  }

  void addCustomer(Customer customer) {
    _repo.addCustomer(customer);
  }

  Future<bool> isCustomerExistByName(String name) async =>
      await _repo.isCustomerExistByName(name);

  void sortById() {
    _repo.sortCustomerById().listen((customer) {
      state = AsyncData(customer);
    }).onError((error) {
      print(error);
    });
  }
}

final customerNotifierProvider =
    AsyncNotifierProvider<CustomerNotifier, List<Customer>>(
        () => CustomerNotifier());
