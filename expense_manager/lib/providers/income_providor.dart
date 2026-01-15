import 'package:expense_manager/data/repositories/income_repo.dart';
import 'package:flutter/material.dart';
import '../data/models/income_model.dart';

class IncomeProvider extends ChangeNotifier {
  final IncomeRepository _repository = IncomeRepository();
  
  List<IncomeModel> _incomes = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<IncomeModel> get incomes => _incomes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load incomes for a user
  void loadIncomes(String userId) {
    print('Loading incomes for user: $userId');
    _repository.getIncomesStream(userId).listen(
      (incomes) {
        print('Received ${incomes.length} incomes');
        _incomes = incomes;
        notifyListeners();
      },
      onError: (error) {
        print('Error loading incomes: $error');
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  // Add income
  Future<bool> addIncome(IncomeModel income) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.addIncome(income);
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

  // Update income
  Future<bool> updateIncome(IncomeModel income) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateIncome(income);
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

  // Delete income
  Future<bool> deleteIncome(String incomeId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteIncome(incomeId);
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

  // Get incomes by date range
  Future<List<IncomeModel>> getIncomesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await _repository.getIncomesByDateRange(userId, startDate, endDate);
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