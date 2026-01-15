import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';

class ExpenseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'expenses';

  // Add expense
  Future<String> addExpense(ExpenseModel expense) async {
    try {
      final docRef = await _firestore.collection(_collection).add(expense.toMap());
      return docRef.id;
    } catch (e) {
      throw 'Failed to add expense: $e';
    }
  }

  // Get all expenses for a user
  Stream<List<ExpenseModel>> getExpensesStream(String userId) {
    print('Setting up expense stream for user: $userId');
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      print('Expense stream received ${snapshot.docs.length} documents');
      return snapshot.docs
          .map((doc) {
            print('Expense doc: ${doc.id}, data: ${doc.data()}');
            return ExpenseModel.fromMap(doc.data(), doc.id);
          })
          .toList();
    });
  }

  // Get expenses by date range
  Future<List<ExpenseModel>> getExpensesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // Firestore doesn't allow multiple inequality filters on different fields
      // So we fetch all user's expenses and filter by date in code
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      final allExpenses = snapshot.docs
          .map((doc) => ExpenseModel.fromMap(doc.data(), doc.id))
          .toList();

      // Filter by date range
      final filteredExpenses = allExpenses.where((expense) {
        return expense.date.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
               expense.date.isBefore(endDate.add(const Duration(seconds: 1)));
      }).toList();

      // Sort by date
      filteredExpenses.sort((a, b) => b.date.compareTo(a.date));

      return filteredExpenses;
    } catch (e) {
      print('Error getting expenses by date range: $e');
      return [];
    }
  }

  // Update expense
  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(expense.id)
          .update(expense.toMap());
    } catch (e) {
      throw 'Failed to update expense: $e';
    }
  }

  // Delete expense
  Future<void> deleteExpense(String expenseId) async {
    try {
      await _firestore.collection(_collection).doc(expenseId).delete();
    } catch (e) {
      throw 'Failed to delete expense: $e';
    }
  }

  // Get total expense for a period
  Future<double> getTotalExpense(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final expenses = await getExpensesByDateRange(userId, startDate, endDate);
      double total = 0.0;
      for (var expense in expenses) {
        total += expense.amount;
      }
      return total;
    } catch (e) {
      return 0.0;
    }
  }

  // Get expenses by category
  Future<Map<String, double>> getExpensesByCategory(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final expenses = await getExpensesByDateRange(userId, startDate, endDate);
      final Map<String, double> categoryTotals = {};

      for (var expense in expenses) {
        categoryTotals[expense.category] = 
            (categoryTotals[expense.category] ?? 0) + expense.amount;
      }

      return categoryTotals;
    } catch (e) {
      return {};
    }
  }
}