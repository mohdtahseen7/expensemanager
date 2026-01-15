import 'package:expense_manager/config/themes/app_colors.dart';
import 'package:expense_manager/data/repositories/expense_repo.dart';
import 'package:expense_manager/data/repositories/income_repo.dart';
import 'package:expense_manager/providers/auth_providor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/date_helper.dart';
import '../../../config/routes/app_routes.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final IncomeRepository _incomeRepository = IncomeRepository();
  final ExpenseRepository _expenseRepository = ExpenseRepository();
  
  bool _isLoading = true;
  
  // Overall stats
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  double _balance = 0.0;
  
  // Income details (current month)
  double _highestIncome = 0.0;
  double _lowestIncome = 0.0;
  double _avgDailyIncome = 0.0;
  String _highestIncomeSource = '';
  String _lowestIncomeSource = '';
  
  // Expense details (current month)
  double _highestExpense = 0.0;
  double _lowestExpense = 0.0;
  double _avgDailyExpense = 0.0;
  String _highestExpenseName = '';
  String _lowestExpenseName = '';

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) return;

    final userId = authProvider.user!.uid;
    final thisMonth = DateHelper.getThisMonth();
    
    try {
      // Get current month's income and expenses
      final incomes = await _incomeRepository.getIncomesByDateRange(
        userId,
        thisMonth.start,
        thisMonth.end,
      );
      
      final expenses = await _expenseRepository.getExpensesByDateRange(
        userId,
        thisMonth.start,
        thisMonth.end,
      );

      // Calculate totals
      _totalIncome = incomes.fold(0.0, (sum, income) => sum + income.amount);
      _totalExpense = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
      _balance = _totalIncome - _totalExpense;

      // Calculate income details
      if (incomes.isNotEmpty) {
        incomes.sort((a, b) => b.amount.compareTo(a.amount));
        _highestIncome = incomes.first.amount;
        _highestIncomeSource = incomes.first.source;
        _lowestIncome = incomes.last.amount;
        _lowestIncomeSource = incomes.last.source;
        
        // Calculate daily average (total / days in month so far)
        final daysInMonth = DateTime.now().day;
        _avgDailyIncome = _totalIncome / daysInMonth;
      }

      // Calculate expense details
      if (expenses.isNotEmpty) {
        expenses.sort((a, b) => b.amount.compareTo(a.amount));
        _highestExpense = expenses.first.amount;
        _highestExpenseName = expenses.first.expenseName;
        _lowestExpense = expenses.last.amount;
        _lowestExpenseName = expenses.last.expenseName;
        
        // Calculate daily average
        final daysInMonth = DateTime.now().day;
        _avgDailyExpense = _totalExpense / daysInMonth;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading reports: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await authProvider.logout();
      
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReports,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadReports,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Month Header
                    Text(
                      DateHelper.getCurrentMonthName(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Income vs Expense Overview
                    const Text(
                      'Income vs Expense',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    _buildOverviewCard(formatter),
                    
                    const SizedBox(height: 24),
                    
                    // Income Details
                    const Text(
                      'Income Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    _buildIncomeDetailsCard(formatter),
                    
                    const SizedBox(height: 24),
                    
                    // Expense Details
                    const Text(
                      'Expense Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    _buildExpenseDetailsCard(formatter),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOverviewCard(NumberFormat formatter) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildOverviewRow('Total Income', _totalIncome, AppColors.income, formatter),
          const Divider(height: 24),
          _buildOverviewRow('Total Expense', _totalExpense, AppColors.expense, formatter),
          const Divider(height: 24),
          _buildOverviewRow(
            'Balance',
            _balance,
            _balance >= 0 ? AppColors.success : AppColors.error,
            formatter,
            isBalance: true,
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewRow(
    String label,
    double amount,
    Color color,
    NumberFormat formatter, {
    bool isBalance = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBalance ? 18 : 16,
            fontWeight: isBalance ? FontWeight.bold : FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          formatter.format(amount),
          style: TextStyle(
            fontSize: isBalance ? 20 : 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildIncomeDetailsCard(NumberFormat formatter) {
    if (_totalIncome == 0) {
      return _buildEmptyCard('No income records for this month');
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow(
            'Highest Income',
            _highestIncomeSource,
            _highestIncome,
            formatter,
            Icons.arrow_upward,
            AppColors.success,
          ),
          const Divider(height: 24),
          _buildDetailRow(
            'Lowest Income',
            _lowestIncomeSource,
            _lowestIncome,
            formatter,
            Icons.arrow_downward,
            AppColors.warning,
          ),
          const Divider(height: 24),
          _buildAverageRow(
            'Daily Average',
            _avgDailyIncome,
            formatter,
            Icons.trending_up,
            AppColors.income,
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseDetailsCard(NumberFormat formatter) {
    if (_totalExpense == 0) {
      return _buildEmptyCard('No expense records for this month');
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow(
            'Highest Expense',
            _highestExpenseName,
            _highestExpense,
            formatter,
            Icons.arrow_upward,
            AppColors.error,
          ),
          const Divider(height: 24),
          _buildDetailRow(
            'Lowest Expense',
            _lowestExpenseName,
            _lowestExpense,
            formatter,
            Icons.arrow_downward,
            AppColors.warning,
          ),
          const Divider(height: 24),
          _buildAverageRow(
            'Daily Average',
            _avgDailyExpense,
            formatter,
            Icons.trending_down,
            AppColors.expense,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String name,
    double amount,
    NumberFormat formatter,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              formatter.format(amount),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAverageRow(
    String label,
    double amount,
    NumberFormat formatter,
    IconData icon,
    Color color,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        Text(
          formatter.format(amount),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}