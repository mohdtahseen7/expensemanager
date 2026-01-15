import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String id;
  final String userId;
  final String expenseName;
  final String category;
  final String description;
  final double amount;
  final DateTime date;
  final DateTime createdAt;

  ExpenseModel({
    required this.id,
    required this.userId,
    required this.expenseName,
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
    required this.createdAt,
  });

  // Expense categories
  static const List<String> categories = [
    'Food',
    'Travel',
    'Bills',
    'Shopping',
    'Others',
  ];

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'expenseName': expenseName,
      'category': category,
      'description': description,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create from Firestore document
  factory ExpenseModel.fromMap(Map<String, dynamic> map, String id) {
    return ExpenseModel(
      id: id,
      userId: map['userId'] ?? '',
      expenseName: map['expenseName'] ?? '',
      category: map['category'] ?? 'Others',
      description: map['description'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Copy with method for updates
  ExpenseModel copyWith({
    String? id,
    String? userId,
    String? expenseName,
    String? category,
    String? description,
    double? amount,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      expenseName: expenseName ?? this.expenseName,
      category: category ?? this.category,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}