import 'dart:convert';

import 'package:iitism_smartid_merchant/models/user.dart';

enum TransactionType { CREDIT, DEBIT }

class Transaction {
  final int id;
  final double amount;
  final TransactionType type;
  final DateTime time;
  final User user;

  Transaction({this.id, this.amount, this.type, this.time, this.user});

  factory Transaction.fromMap(Map data) {
    TransactionType type;
    switch (data['type']) {
      case 'credit':
        type = TransactionType.CREDIT;
        break;
      case 'debit':
        type = TransactionType.DEBIT;
        break;
      default:
    }
    return Transaction( 
      amount: double.parse(data['amount'].toString()) ?? 0.0,
      type: type,
      time: DateTime.parse(data['created_at']),
      user: User.fromMap(data['user'])
    );
  }
}
