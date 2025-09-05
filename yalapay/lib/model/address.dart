class Address {
  String street;
  String city;
  String country;

  Address({
    required this.street,
    required this.city,
    required this.country,
  });

  factory Address.fromJson(Map<String, dynamic> map) {
    return Address(
      street: map['street'],
      city: map['city'],
      country: map['country'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'country': country,
    };
  }
}