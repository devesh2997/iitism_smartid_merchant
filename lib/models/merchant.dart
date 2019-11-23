import 'dart:convert';

class Merchant {
  final int merchantId;
  final String businessName;
  final String firstName;
  final String middleName;
  final String lastName;
  final String email;
  final double balance;

  Merchant({
    this.merchantId,
    this.businessName,
    this.firstName,
    this.middleName,
    this.lastName,
    this.email,
    this.balance,
  });

  factory Merchant.fromMap(Map data) {
    return Merchant(
        merchantId: data['id'],
        businessName: data['business_name'] ?? '',
        firstName: data['first_name'] ?? '',
        middleName: data['middle_name'] ?? '',
        lastName: data['last_name'] ?? '',
        email: data['email'] ?? '',
        balance: double.parse(data['balance'].toString()));
  }
}
