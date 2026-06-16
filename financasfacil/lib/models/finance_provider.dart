import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'transaction.dart';

class FinanceProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  double _goal = 500.0;
  static const _uuid = Uuid();

  List<Transaction> get transactions => List.unmodifiable(_transactions);
  double get goal => _goal;

  double get totalIncome => _transactions
      .where((t) => t.type == 'income')
      .fold(0, (s, t) => s + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == 'expense')
      .fold(0, (s, t) => s + t.amount);

  double get balance => totalIncome - totalExpense;

  int get savingsPct =>
      totalIncome > 0 ? ((balance / totalIncome) * 100).round() : 0;

  bool get overGoal => totalExpense > _goal;

  List<Transaction> get recent =>
      [..._transactions]..sort((a, b) => b.date.compareTo(a.date));

  Map<String, double> get byCategory {
    final map = <String, double>{};
    for (final t in _transactions.where((t) => t.type == 'expense')) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  /// Returns expense totals for last [months] months (oldest first)
  List<Map<String, dynamic>> monthlyExpenses({int months = 6}) {
    final now = DateTime.now();
    return List.generate(months, (i) {
      final d = DateTime(now.year, now.month - (months - 1 - i), 1);
      final key = '${d.year}-${d.month.toString().padLeft(2, '0')}';
      final total = _transactions
          .where((t) =>
              t.type == 'expense' &&
              '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}' == key)
          .fold(0.0, (s, t) => s + t.amount);
      return {'month': _monthName(d.month), 'total': total};
    });
  }

  String _monthName(int m) =>
      ['Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'][m - 1];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('transactions') ?? [];
    _transactions = raw.map((s) => Transaction.fromJson(s)).toList();
    _goal = prefs.getDouble('goal') ?? 500.0;

    // seed data if empty
    if (_transactions.isEmpty) {
      final now = DateTime.now();
      _transactions = [
        Transaction(id: _uuid.v4(), desc: 'Salário', amount: 3500, type: 'income', category: 'other', date: DateTime(now.year, now.month, 1)),
        Transaction(id: _uuid.v4(), desc: 'Supermercado', amount: 420, type: 'expense', category: 'food', date: DateTime(now.year, now.month, 5)),
        Transaction(id: _uuid.v4(), desc: 'Uber', amount: 38, type: 'expense', category: 'transport', date: DateTime(now.year, now.month, 8)),
        Transaction(id: _uuid.v4(), desc: 'Netflix', amount: 55, type: 'expense', category: 'leisure', date: DateTime(now.year, now.month, 10)),
        Transaction(id: _uuid.v4(), desc: 'Luz', amount: 180, type: 'expense', category: 'bills', date: DateTime(now.year, now.month, 12)),
      ];
      await _save();
    }
    notifyListeners();
  }

  Future<void> addTransaction(Transaction t) async {
    _transactions.add(t);
    await _save();
    notifyListeners();
  }

  Future<void> removeTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> setGoal(double value) async {
    _goal = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('goal', value);
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'transactions', _transactions.map((t) => t.toJson()).toList());
  }

  String newId() => _uuid.v4();
}
