import 'package:expense_manager/config/themes/app_colors.dart';
import 'package:expense_manager/providers/auth_providor.dart';
import 'package:expense_manager/providers/income_providor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../data/models/income_model.dart';
import '../../../config/routes/app_routes.dart';

class IncomeListScreen extends StatefulWidget {
  const IncomeListScreen({Key? key}) : super(key: key);

  @override
  State<IncomeListScreen> createState() => _IncomeListScreenState();
}

class _IncomeListScreenState extends State<IncomeListScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  List<IncomeModel> _filteredIncomes = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final incomeProvider = Provider.of<IncomeProvider>(context, listen: false);
      
      if (authProvider.user != null) {
        incomeProvider.loadIncomes(authProvider.user!.uid);
      }
    });
  }

  void _filterIncomes(List<IncomeModel> allIncomes) {
    if (_startDate == null || _endDate == null) {
      _filteredIncomes = allIncomes;
      return;
    }

    _filteredIncomes = allIncomes.where((income) {
      return income.date.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
             income.date.isBefore(_endDate!.add(const Duration(days: 1)));
    }).toList();
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _clearFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
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

    if (confirmed == true && context.mounted) {
      await authProvider.logout();
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Income'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _selectDateRange,
            tooltip: 'Filter by date',
          ),
          if (_startDate != null || _endDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearFilter,
              tooltip: 'Clear filter',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final incomeProvider = Provider.of<IncomeProvider>(context, listen: false);
              if (authProvider.user != null) {
                incomeProvider.loadIncomes(authProvider.user!.uid);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Consumer<IncomeProvider>(
        builder: (context, incomeProvider, child) {
          _filterIncomes(incomeProvider.incomes);
          
          // Calculate total
          final total = _filteredIncomes.fold<double>(
            0.0,
            (sum, income) => sum + income.amount,
          );
          
          return Column(
            children: [
              // Date filter display
              if (_startDate != null && _endDate != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  color: AppColors.primary.withOpacity(0.1),
                  child: Row(
                    children: [
                      const Icon(Icons.date_range, size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Showing: ${DateFormat('dd MMM yyyy').format(_startDate!)} - ${DateFormat('dd MMM yyyy').format(_endDate!)}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${_filteredIncomes.length} records',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Income list
              Expanded(
                child: _filteredIncomes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 80,
                              color: AppColors.textSecondary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _startDate != null
                                  ? 'No income records in selected date range'
                                  : 'No income records yet',
                              style: const TextStyle(
                                fontSize: 18,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Tap the + button to add your first income',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textHint,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredIncomes.length,
                        itemBuilder: (context, index) {
                          final income = _filteredIncomes[index];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.income.withOpacity(0.2),
                                child: const Icon(
                                  Icons.arrow_downward,
                                  color: AppColors.income,
                                ),
                              ),
                              title: Text(
                                income.source,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (income.description.isNotEmpty)
                                    Text(
                                      income.description,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('dd MMM yyyy').format(income.date),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Text(
                                '₹${income.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.income,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              
              // Total at bottom - Always show when there's data
              if (incomeProvider.incomes.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _startDate != null ? 'Filtered Total:' : 'Total Income:',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '₹${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.income,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}