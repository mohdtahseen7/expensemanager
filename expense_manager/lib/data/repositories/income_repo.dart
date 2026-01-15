import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/income_model.dart';

class IncomeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'incomes';

  // Add income
  Future<String> addIncome(IncomeModel income) async {
    try {
      final docRef = await _firestore.collection(_collection).add(income.toMap());
      return docRef.id;
    } catch (e) {
      throw 'Failed to add income: $e';
    }
  }

  // Get all incomes for a user
  Stream<List<IncomeModel>> getIncomesStream(String userId) {
    print('Setting up income stream for user: $userId');
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      print('Income stream received ${snapshot.docs.length} documents');
      return snapshot.docs
          .map((doc) {
            print('Income doc: ${doc.id}, data: ${doc.data()}');
            return IncomeModel.fromMap(doc.data(), doc.id);
          })
          .toList();
    });
  }

  // Get incomes by date range
  Future<List<IncomeModel>> getIncomesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // Firestore doesn't allow multiple inequality filters on different fields
      // So we fetch all user's incomes and filter by date in code
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      final allIncomes = snapshot.docs
          .map((doc) => IncomeModel.fromMap(doc.data(), doc.id))
          .toList();

      // Filter by date range
      final filteredIncomes = allIncomes.where((income) {
        return income.date.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
               income.date.isBefore(endDate.add(const Duration(seconds: 1)));
      }).toList();

      // Sort by date
      filteredIncomes.sort((a, b) => b.date.compareTo(a.date));

      return filteredIncomes;
    } catch (e) {
      print('Error getting incomes by date range: $e');
      return [];
    }
  }

  // Update income
  Future<void> updateIncome(IncomeModel income) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(income.id)
          .update(income.toMap());
    } catch (e) {
      throw 'Failed to update income: $e';
    }
  }

  // Delete income
  Future<void> deleteIncome(String incomeId) async {
    try {
      await _firestore.collection(_collection).doc(incomeId).delete();
    } catch (e) {
      throw 'Failed to delete income: $e';
    }
  }

  // Get total income for a period
  Future<double> getTotalIncome(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final incomes = await getIncomesByDateRange(userId, startDate, endDate);
      double total = 0.0;
      for (var income in incomes) {
        total += income.amount;
      }
      return total;
    } catch (e) {
      return 0.0;
    }
  }
}