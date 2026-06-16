import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/finance_provider.dart';
import '../theme.dart';

class AiTipScreen extends StatefulWidget {
  const AiTipScreen({super.key});

  @override
  State<AiTipScreen> createState() => _AiTipScreenState();
}

class _AiTipScreenState extends State<AiTipScreen> {
  String _tip = '';
  bool _loading = false;

  String brl(double v) =>
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(v);

  Future<void> _getTip() async {
    setState(() { _loading = true; _tip = ''; });
    final fp = context.read<FinanceProvider>();
    final cats = fp.byCategory.entries
        .map((e) => '${e.key}: ${brl(e.value)}')
        .join(', ');
    final summary =
        'Receita: ${brl(fp.totalIncome)}, Despesas: ${brl(fp.totalExpense)}, '
        'Saldo: ${brl(fp.balance)}. Gastos por categoria: $cats. '
        'Meta de economia: ${brl(fp.goal)}.';

    try {
      final res = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'Content-Type': 'application/json',
          'anthropic-version': '2023-06-01',
        },
        body: json.encode({
          'model': 'claude-sonnet-4-6',
          'max_tokens': 1000,
          'system':
              'Você é um consultor financeiro brasileiro. Dê 3 dicas práticas e motivadoras em português com base nos dados. Use emojis. Máximo 150 palavras.',
          'messages': [
            {'role': 'user', 'content': 'Analise e dê dicas: $summary'}
          ],
        }),
      );
      final data = json.decode(utf8.decode(res.bodyBytes));
      setState(() => _tip = data['content']?[0]?['text'] ?? 'Sem resposta.');
    } catch (e) {
      setState(() => _tip = 'Erro ao conectar. Verifique sua internet.');
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final fp = context.watch<FinanceProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text('🤖 Assistente IA',
              style: TextStyle(
                  color: AppTheme.textMain,
                  fontSize: 22,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('Análise personalizada das suas finanças',
              style: TextStyle(color: AppTheme.textSub, fontSize: 13)),
          const SizedBox(height: 24),

          // Resumo rápido
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: [
                _row('💰 Receita total', brl(fp.totalIncome), AppTheme.income),
                _row('💸 Despesa total', brl(fp.totalExpense), AppTheme.expense),
                _row('📊 Economia', '${fp.savingsPct}%', AppTheme.primary),
                _row('🎯 Meta', brl(fp.goal),
                    fp.overGoal ? AppTheme.warning : AppTheme.income),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Botão IA
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: kPrimaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _loading ? null : _getTip,
                icon: _loading
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.auto_awesome, color: Colors.white),
                label: Text(
                  _loading ? 'Analisando...' : '✨ Gerar dica personalizada',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
              ),
            ),
          ),

          if (_tip.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF12122A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
              ),
              child: Text(_tip,
                  style: const TextStyle(
                      color: Color(0xFFC4B5FD),
                      fontSize: 14,
                      height: 1.6)),
            ),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _row(String label, String value, Color color) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppTheme.textSub, fontSize: 13)),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
          ],
        ),
      );
}
