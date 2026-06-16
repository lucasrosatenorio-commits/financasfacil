import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'models/finance_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/ai_tip_screen.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const FinancasFacilApp());
}

class FinancasFacilApp extends StatelessWidget {
  const FinancasFacilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FinanceProvider()..load(),
      child: MaterialApp(
        title: 'FinançasFácil',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const HomeShell(),
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final _screens = const [
    DashboardScreen(),
    AddTransactionScreen(),
    AiTipScreen(),
  ];

  final _labels = const ['Início', 'Adicionar', 'Dica IA'];
  final _icons = const [Icons.home_rounded, Icons.add_circle_rounded, Icons.auto_awesome_rounded];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('💰 ',
                style: TextStyle(fontSize: 20)),
            ShaderMask(
              shaderCallback: (bounds) =>
                  kPrimaryGradient.createShader(bounds),
              child: const Text('FinançasFácil',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18)),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              _monthYear(),
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 13),
            ),
          )
        ],
      ),
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          backgroundColor: AppTheme.surface,
          selectedItemColor: const Color(0xFFA78BFA),
          unselectedItemColor: AppTheme.textMuted,
          type: BottomNavigationBarType.fixed,
          items: List.generate(
            3,
            (i) => BottomNavigationBarItem(
              icon: Icon(_icons[i]),
              label: _labels[i],
            ),
          ),
        ),
      ),
    );
  }

  String _monthYear() {
    final now = DateTime.now();
    const months = [
      'Jan','Fev','Mar','Abr','Mai','Jun',
      'Jul','Ago','Set','Out','Nov','Dez'
    ];
    return '${months[now.month - 1]} ${now.year}';
  }
}
