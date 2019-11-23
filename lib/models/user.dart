class User {
  final String firstName;
  final String middleName;
  final String lastName;

  User({
    this.firstName,
    this.middleName,
    this.lastName,
  });

  factory User.fromMap(Map map) {
    return User(
      firstName: map['first_name'] ?? '',
      middleName: map['middle_name'] ?? '',
      lastName: map['last_name'],
    );
  }
}
