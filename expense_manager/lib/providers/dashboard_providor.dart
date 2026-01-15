import 'package:expense_manager/data/repositories/expense_repo.dart';
import 'package:expense_manager/data/repositories/income_repo.dart';
import 'package:flutter/material.dart';
import '../core/utils/date_helper.dart';

class DashboardProvider extends ChangeNotifier {
  final IncomeRepository _incomeRepository = IncomeRepository();
  final ExpenseRepository _expenseRepository = ExpenseRepository();

  bool _isLoading = false;
  String? _errorMessage;

  // Today's data
  double _todayIncome = 0.0;
  double _todayExpense = 0.0;

  // This week's data
  double _weekIncome = 0.0;
  double _weekExpense = 0.0;

  // This month's data
  double _monthIncome = 0.0;
  double _monthExpense = 0.0;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  double get todayIncome => _todayIncome;
  double get todayExpense => _todayExpense;
  double get todayBalance => _todayIncome - _todayExpense;
  
  double get weekIncome => _weekIncome;
  double get weekExpense => _weekExpense;
  double get weekBalance => _weekIncome - _weekExpense;
  
  double get monthIncome => _monthIncome;
  double get monthExpense => _monthExpense;
  double get monthBalance => _monthIncome - _monthExpense;

  // Load all dashboard data
  Future<void> loadDashboardData(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('Loading dashboard data for user: $userId');
      
      // Get date ranges
      final today = DateHelper.getToday();
      final thisWeek = DateHelper.getThisWeek();
      final thisMonth = DateHelper.getThisMonth();

      print('Today: ${today.start} to ${today.end}');
      print('This Week: ${thisWeek.start} to ${thisWeek.end}');
      print('This Month: ${thisMonth.start} to ${thisMonth.end}');

      // Load today's data
      _todayIncome = await _incomeRepository.getTotalIncome(
        userId,
        today.start,
        today.end,
      );
      _todayExpense = await _expenseRepository.getTotalExpense(
        userId,
        today.start,
        today.end,
      );
      print('Today - Income: $_todayIncome, Expense: $_todayExpense');

      // Load this week's data
      _weekIncome = await _incomeRepository.getTotalIncome(
        userId,
        thisWeek.start,
        thisWeek.end,
      );
      _weekExpense = await _expenseRepository.getTotalExpense(
        userId,
        thisWeek.start,
        thisWeek.end,
      );
      print('Week - Income: $_weekIncome, Expense: $_weekExpense');

      // Load this month's data
      _monthIncome = await _incomeRepository.getTotalIncome(
        userId,
        thisMonth.start,
        thisMonth.end,
      );
      _monthExpense = await _expenseRepository.getTotalExpense(
        userId,
        thisMonth.start,
        thisMonth.end,
      );
      print('Month - Income: $_monthIncome, Expense: $_monthExpense');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading dashboard: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh dashboard
  Future<void> refresh(String userId) async {
    await loadDashboardData(userId);
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}