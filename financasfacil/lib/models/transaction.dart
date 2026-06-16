import 'dart:convert';

class Transaction {
  final String id;
  final String desc;
  final double amount;
  final String type; // 'income' or 'expense'
  final String category;
  final DateTime date;

  Transaction({
    required this.id,
    required this.desc,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'desc': desc,
    'amount': amount,
    'type': type,
    'category': category,
    'date': date.toIso8601String(),
  };

  factory Transaction.fromMap(Map<String, dynamic> map) => Transaction(
    id: map['id'],
    desc: map['desc'],
    amount: map['amount'],
    type: map['type'],
    category: map['category'],
    date: DateTime.parse(map['date']),
  );

  String toJson() => json.encode(toMap());
  factory Transaction.fromJson(String source) =>
      Transaction.fromMap(json.decode(source));
}

class Category {
  final String id;
  final String label;
  final String emoji;
  final int color; // ARGB int

  const Category({
    required this.id,
    required this.label,
    required this.emoji,
    required this.color,
  });
}

const List<Category> kCategories = [
  Category(id: 'food',      label: 'Alimentação', emoji: '🍔', color: 0xFFFF6B6B),
  Category(id: 'transport', label: 'Transporte',  emoji: '🚗', color: 0xFF4ECDC4),
  Category(id: 'health',    label: 'Saúde',       emoji: '💊', color: 0xFF45B7D1),
  Category(id: 'leisure',   label: 'Lazer',       emoji: '🎮', color: 0xFF96CEB4),
  Category(id: 'bills',     label: 'Contas',      emoji: '💡', color: 0xFFFFEAA7),
  Category(id: 'other',     label: 'Outros',      emoji: '📦', color: 0xFFDDA0DD),
];

Category categoryById(String id) =>
    kCategories.firstWhere((c) => c.id == id, orElse: () => kCategories.last);
