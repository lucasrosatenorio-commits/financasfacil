import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/finance_provider.dart';
import '../theme.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _descCtrl = TextEditingController();
  final _amtCtrl = TextEditingController();
  String _type = 'expense';
  String _category = 'food';
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _descCtrl.dispose();
    _amtCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    if (_descCtrl.text.isEmpty || _amtCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha descrição e valor!')),
      );
      return;
    }
    final amt = double.tryParse(_amtCtrl.text.replaceAll(',', '.'));
    if (amt == null || amt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Valor inválido!')),
      );
      return;
    }
    final fp = context.read<FinanceProvider>();
    fp.addTransaction(Transaction(
      id: fp.newId(),
      desc: _descCtrl.text.trim(),
      amount: amt,
      type: _type,
      category: _category,
      date: _date,
    ));
    _descCtrl.clear();
    _amtCtrl.clear();
    setState(() {
      _type = 'expense';
      _category = 'food';
      _date = DateTime.now();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Transação adicionada!'),
        backgroundColor: AppTheme.income,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text('Nova Transação',
              style: TextStyle(
                  color: AppTheme.textMain,
                  fontSize: 22,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 24),

          // ── TIPO ──────────────────────────────────────────
          _label('TIPO'),
          Row(
            children: [
              _typeBtn('expense', '↓ Despesa', AppTheme.expense),
              const SizedBox(width: 10),
              _typeBtn('income', '↑ Receita', AppTheme.income),
            ],
          ),
          const SizedBox(height: 16),

          // ── DESCRIÇÃO ─────────────────────────────────────
          _label('DESCRIÇÃO'),
          _inputField(
            controller: _descCtrl,
            hint: 'Ex: Supermercado',
          ),
          const SizedBox(height: 16),

          // ── VALOR ─────────────────────────────────────────
          _label('VALOR (R\$)'),
          _inputField(
            controller: _amtCtrl,
            hint: '0,00',
            numeric: true,
          ),
          const SizedBox(height: 16),

          // ── CATEGORIA ─────────────────────────────────────
          if (_type == 'expense') ...[
            _label('CATEGORIA'),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 3.5,
              children: kCategories.map((cat) {
                final active = _category == cat.id;
                return GestureDetector(
                  onTap: () => setState(() => _category = cat.id),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: active ? AppTheme.primary : AppTheme.border),
                      color: active
                          ? AppTheme.primary.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${cat.emoji} ${cat.label}',
                      style: TextStyle(
                        color: active ? const Color(0xFFA78BFA) : AppTheme.textMuted,
                        fontSize: 12,
                        fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // ── DATA ──────────────────────────────────────────
          _label('DATA'),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF12122A),
                border: Border.all(color: AppTheme.surface2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                DateFormat('dd/MM/yyyy').format(_date),
                style: const TextStyle(color: AppTheme.textMain, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // ── BOTÃO ─────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: kPrimaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _save,
                child: const Text('Adicionar',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                color: AppTheme.textSub,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8)),
      );

  Widget _inputField(
          {required TextEditingController controller,
          required String hint,
          bool numeric = false}) =>
      TextField(
        controller: controller,
        keyboardType: numeric ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: AppTheme.textMain, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppTheme.textMuted),
          filled: true,
          fillColor: const Color(0xFF12122A),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: AppTheme.surface2),
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppTheme.surface2),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppTheme.primary),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

  Widget _typeBtn(String type, String label, Color activeColor) => Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _type = type),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: _type == type ? activeColor : AppTheme.surface2,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(label,
                style: TextStyle(
                    color: _type == type ? Colors.white : AppTheme.textMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
          ),
        ),
      );
}
