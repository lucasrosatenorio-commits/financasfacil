import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/finance_provider.dart';
import '../models/transaction.dart';
import '../theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String brl(double v) =>
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(v);

  @override
  Widget build(BuildContext context) {
    final fp = context.watch<FinanceProvider>();
    final monthly = fp.monthlyExpenses();
    final maxBar = monthly.fold(1.0, (m, e) => e['total'] > m ? e['total'] : m);
    final catData = fp.byCategory;
    final sortedCats = kCategories
        .where((c) => (catData[c.id] ?? 0) > 0)
        .toList()
      ..sort((a, b) => (catData[b.id] ?? 0).compareTo(catData[a.id] ?? 0));

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── BALANCE CARD ──────────────────────────────────
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: kPrimaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('SALDO ATUAL',
                    style: TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                        letterSpacing: 1.2)),
                const SizedBox(height: 6),
                Text(brl(fp.balance),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _miniCard('↑ Receita', brl(fp.totalIncome)),
                    const SizedBox(width: 10),
                    _miniCard('↓ Despesa', brl(fp.totalExpense)),
                    const SizedBox(width: 10),
                    _miniCard('📊 Economia', '${fp.savingsPct}%'),
                  ],
                )
              ],
            ),
          ),

          // ── META ──────────────────────────────────────────
          _section(
            title: 'Meta de Gastos',
            child: _GoalCard(),
          ),

          // ── GRÁFICO MENSAL ────────────────────────────────
          _section(
            title: 'Gastos por Mês',
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDeco(),
              child: SizedBox(
                height: 120,
                child: BarChart(
                  BarChartData(
                    maxY: maxBar * 1.2,
                    barGroups: List.generate(monthly.length, (i) {
                      final isLast = i == monthly.length - 1;
                      return BarChartGroupData(x: i, barRods: [
                        BarChartRodData(
                          toY: (monthly[i]['total'] as double),
                          color: isLast
                              ? AppTheme.primary
                              : AppTheme.surface2,
                          width: 18,
                          borderRadius: BorderRadius.circular(6),
                        )
                      ]);
                    }),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) => Text(
                            monthly[v.toInt()]['month'],
                            style: const TextStyle(
                                color: AppTheme.textMuted, fontSize: 10),
                          ),
                        ),
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
            ),
          ),

          // ── POR CATEGORIA ─────────────────────────────────
          if (sortedCats.isNotEmpty)
            _section(
              title: 'Por Categoria',
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: _cardDeco(),
                child: Column(
                  children: sortedCats.map((cat) {
                    final total = catData[cat.id] ?? 0;
                    final pct = fp.totalExpense > 0
                        ? total / fp.totalExpense
                        : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10, height: 10,
                                decoration: BoxDecoration(
                                  color: Color(cat.color),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text('${cat.emoji} ${cat.label}',
                                  style: const TextStyle(
                                      color: AppTheme.textMain, fontSize: 13)),
                              const Spacer(),
                              Text(brl(total),
                                  style: const TextStyle(
                                      color: AppTheme.textMain,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 5),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              value: pct,
                              backgroundColor: AppTheme.surface2,
                              valueColor: AlwaysStoppedAnimation(Color(cat.color)),
                              minHeight: 4,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          // ── TRANSAÇÕES RECENTES ───────────────────────────
          _section(
            title: 'Últimas Transações',
            child: Container(
              decoration: _cardDeco(),
              child: Column(
                children: fp.recent.take(8).map((t) {
                  final cat = categoryById(t.category);
                  return ListTile(
                    leading: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.surface2,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                          child: Text(cat.emoji,
                              style: const TextStyle(fontSize: 18))),
                    ),
                    title: Text(t.desc,
                        style: const TextStyle(
                            color: AppTheme.textMain,
                            fontWeight: FontWeight.w500)),
                    subtitle: Text(
                      DateFormat('dd/MM/yyyy').format(t.date),
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 11),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${t.type == 'income' ? '+' : '-'}${brl(t.amount)}',
                          style: TextStyle(
                            color: t.type == 'income'
                                ? AppTheme.income
                                : AppTheme.expense,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close,
                              size: 16, color: AppTheme.textMuted),
                          onPressed: () =>
                              context.read<FinanceProvider>().removeTransaction(t.id),
                        )
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniCard(String label, String value) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.white60, fontSize: 10)),
              const SizedBox(height: 3),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12)),
            ],
          ),
        ),
      );

  Widget _section({required String title, required Widget child}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title.toUpperCase(),
                style: const TextStyle(
                    color: AppTheme.textSub,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8)),
            const SizedBox(height: 10),
            child,
          ],
        ),
      );

  BoxDecoration _cardDeco() => BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      );
}

// ── META CARD ──────────────────────────────────────────────
class _GoalCard extends StatefulWidget {
  @override
  State<_GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<_GoalCard> {
  bool _editing = false;
  final _ctrl = TextEditingController();

  String brl(double v) =>
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(v);

  @override
  Widget build(BuildContext context) {
    final fp = context.watch<FinanceProvider>();
    final pct = (fp.totalExpense / fp.goal).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: _editing
          ? Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppTheme.textMain),
                    decoration: const InputDecoration(
                      hintText: 'Meta em R\$',
                      hintStyle: TextStyle(color: AppTheme.textMuted),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary),
                  onPressed: () {
                    final v = double.tryParse(_ctrl.text);
                    if (v != null) context.read<FinanceProvider>().setGoal(v);
                    setState(() => _editing = false);
                  },
                  child: const Text('OK'),
                )
              ],
            )
          : Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      fp.overGoal ? '⚠️ Meta ultrapassada!' : '🎯 Dentro da meta',
                      style: const TextStyle(
                          color: AppTheme.textMain, fontSize: 13),
                    ),
                    GestureDetector(
                      onTap: () {
                        _ctrl.text = fp.goal.toStringAsFixed(0);
                        setState(() => _editing = true);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.primary),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Editar',
                            style: TextStyle(
                                color: AppTheme.primary, fontSize: 12)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: AppTheme.surface2,
                    valueColor: AlwaysStoppedAnimation(
                        fp.overGoal ? AppTheme.warning : AppTheme.primary),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${brl(fp.totalExpense)} de ${brl(fp.goal)}',
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 12),
                  ),
                ),
              ],
            ),
    );
  }
}
