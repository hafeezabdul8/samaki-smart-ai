import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/auth_provider.dart';
import '../services/api_service.dart';
import '../services/language_provider.dart';
import 'dashboard_screen.dart';
import 'orders_screen.dart';
import 'alerts_screen.dart';
import 'forecast_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final api = context.read<ApiService>();
    final lang = context.watch<LanguageProvider>();

    final screens = [
      DashboardScreen(api: api),
      const OrdersScreen(),
      const AlertsScreen(),
      const ForecastScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(Icons.dashboard_rounded, lang.t('Prices', 'Bei'), 0),
                _navItem(Icons.receipt_long_rounded, lang.t('Orders', 'Maagizo'), 1),
                _navItem(Icons.warning_amber_rounded, lang.t('Alerts', 'Tahadhari'), 2),
                _navItem(Icons.trending_up_rounded, lang.t('Forecast', 'Utabiri'), 3),
                _navItem(Icons.person_rounded, lang.t('Profile', 'Wasifu'), 4),
                GestureDetector(
                  onTap: () => lang.toggle(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🇹🇿', style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(
                          lang.locale.languageCode == 'en' ? 'EN' : 'SW',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 8, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final active = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppTheme.blueAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: active ? Colors.white : Colors.grey.shade500, size: 18),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : Colors.grey.shade500,
                fontSize: 8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}