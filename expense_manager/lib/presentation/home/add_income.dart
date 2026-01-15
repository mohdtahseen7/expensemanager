import 'package:expense_manager/config/themes/app_colors.dart';
import 'package:expense_manager/core/utils/validator.dart';
import 'package:expense_manager/providers/auth_providor.dart';
import 'package:expense_manager/providers/dashboard_providor.dart';
import 'package:expense_manager/providers/income_providor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../data/models/income_model.dart';


class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({Key? key}) : super(key: key);

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sourceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _sourceController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final incomeProvider = Provider.of<IncomeProvider>(context, listen: false);

      if (authProvider.user == null) return;

      final income = IncomeModel(
        id: '',
        userId: authProvider.user!.uid,
        date: _selectedDate,
        source: _sourceController.text.trim(),
        description: _descriptionController.text.trim(),
        amount: double.parse(_amountController.text),
        createdAt: DateTime.now(),
      );

      final success = await incomeProvider.addIncome(income);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Income added successfully!'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 1),
          ),
        );
        Navigator.of(context).pop();
        
        // Refresh dashboard asynchronously (don't wait)
        final dashboardProvider = Provider.of<IncomeProvider>(context, listen: false);
        dashboardProvider.loadIncomes(authProvider.user!.uid);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(incomeProvider.errorMessage ?? 'Failed to add income'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Income'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Date Field
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    DateFormat('dd MMM yyyy').format(_selectedDate),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Income Source
              TextFormField(
                controller: _sourceController,
                decoration: const InputDecoration(
                  labelText: 'Income Source',
                  hintText: '',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) => Validators.validateRequired(value, 'Income source'),
              ),
              
              const SizedBox(height: 16),
              
              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter details (optional)',
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Amount
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  hintText: 'Enter amount',
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                validator: Validators.validateAmount,
              ),
              
              const SizedBox(height: 32),
              
              // Submit Button
              Consumer<IncomeProvider>(
                builder: (context, incomeProvider, child) {
                  return ElevatedButton(
                    onPressed: incomeProvider.isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.income,
                    ),
                    child: incomeProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Add Income',
                            style: TextStyle(fontSize: 16),
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}