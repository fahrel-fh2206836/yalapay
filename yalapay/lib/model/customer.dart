import 'package:yalapay/model/address.dart';
import 'package:yalapay/model/contact_details.dart';

class Customer {
  final String id;
  final String companyName;
  final Address address;
  final ContactDetails contactDetails;

  Customer({
    required this.id,
    required this.companyName,
    required this.address,
    required this.contactDetails,
  });

  factory Customer.fromJson(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      companyName: map['companyName'],
      address: Address.fromJson(map['address']),
      contactDetails: ContactDetails.fromJson(map['contactDetails']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyName': companyName,
      'address': address.toJson(),
      'contactDetails': contactDetails.toJson(),
    };
  }
}