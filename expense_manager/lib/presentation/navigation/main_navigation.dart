import 'package:expense_manager/config/themes/app_colors.dart';
import 'package:expense_manager/presentation/home/add_expense.dart';
import 'package:expense_manager/presentation/home/add_income.dart';
import 'package:expense_manager/presentation/home/expense_list.dart';
import 'package:expense_manager/presentation/home/home_screen.dart';
import 'package:expense_manager/presentation/home/income_list.dart';
import 'package:expense_manager/presentation/home/report_screen.dart';
import 'package:expense_manager/providers/auth_providor.dart';
import 'package:expense_manager/providers/expense_providor.dart';
import 'package:expense_manager/providers/income_providor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final incomeProvider = Provider.of<IncomeProvider>(context, listen: false);
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    
    if (authProvider.user != null) {
      incomeProvider.loadIncomes(authProvider.user!.uid);
      expenseProvider.loadExpenses(authProvider.user!.uid);
    }
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const IncomeListScreen(),
    const ExpenseListScreen(),
    const ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_downward_outlined),
            activeIcon: Icon(Icons.arrow_downward),
            label: 'Income',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_upward_outlined),
            activeIcon: Icon(Icons.arrow_upward),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment_outlined),
            activeIcon: Icon(Icons.assessment),
            label: 'Reports',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? null
          : _currentIndex == 1
              ? FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AddIncomeScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Income'),
                  backgroundColor: AppColors.income,
                )
              : _currentIndex == 2
                  ? FloatingActionButton.extended(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AddExpenseScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Expense'),
                      backgroundColor: AppColors.expense,
                    )
                  : null,
    );
  }
}