import 'package:expense_manager/data/repositories/expense_repo.dart';
import 'package:flutter/material.dart';
import '../data/models/expense_model.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseRepository _repository = ExpenseRepository();
  
  List<ExpenseModel> _expenses = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ExpenseModel> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load expenses for a user
  void loadExpenses(String userId) {
    print('Loading expenses for user: $userId');
    _repository.getExpensesStream(userId).listen(
      (expenses) {
        print('Received ${expenses.length} expenses');
        _expenses = expenses;
        notifyListeners();
      },
      onError: (error) {
        print('Error loading expenses: $error');
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  // Add expense
  Future<bool> addExpense(ExpenseModel expense) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.addExpense(expense);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update expense
  Future<bool> updateExpense(ExpenseModel expense) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateExpense(expense);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete expense
  Future<bool> deleteExpense(String expenseId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteExpense(expenseId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get expenses by date range
  Future<List<ExpenseModel>> getExpensesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await _repository.getExpensesByDateRange(userId, startDate, endDate);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}