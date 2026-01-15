import 'package:cloud_firestore/cloud_firestore.dart';

class IncomeModel {
  final String id;
  final String userId;
  final DateTime date;
  final String source;
  final String description;
  final double amount;
  final DateTime createdAt;

  IncomeModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.source,
    required this.description,
    required this.amount,
    required this.createdAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'source': source,
      'description': description,
      'amount': amount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create from Firestore document
  factory IncomeModel.fromMap(Map<String, dynamic> map, String id) {
    return IncomeModel(
      id: id,
      userId: map['userId'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      source: map['source'] ?? '',
      description: map['description'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Copy with method for updates
  IncomeModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    String? source,
    String? description,
    double? amount,
    DateTime? createdAt,
  }) {
    return IncomeModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      source: source ?? this.source,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}