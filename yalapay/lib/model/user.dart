class User {
  String email;
  String password;
  String firstName;
  String lastName;

  User ({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName
  });

  factory User.fromJson(Map<String, dynamic> map){
    return User(
      email: map['email'], 
      password: map['password'], 
      firstName: map['firstName'], 
      lastName: map['lastName']
      );
  }
}

