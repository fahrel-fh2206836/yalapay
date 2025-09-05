import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:yalapay/model/customer.dart';

class CustomerRepository {
  List<Customer> customers = [];

  Future<List<Customer>> getCustomers() async {
    String data = await rootBundle.loadString('assets/data/customers.json');
    var customersMap = jsonDecode(data);
    for (var customerMap in customersMap) {
      customers.add(Customer.fromJson(customerMap));
    }
    return customers;
  }
}
