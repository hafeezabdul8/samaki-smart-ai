import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/language_provider.dart';

class ForecastScreen extends StatefulWidget {
  const ForecastScreen({super.key});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  List<dynamic> _forecast = [];
  bool _loading = false;
  bool _hasData = false;
  String _species = 'Yellowfin Tuna';
  String _market = 'Darajani Market';

  final _speciesList = [
    'Yellowfin Tuna', 'Octopus/Squid', 'Lobster', 'Kingfish', 'Snapper',
    'Swordfish', 'Barracuda', 'Anchovy', 'Sardine', 'Mackerel',
    'Rabbitfish', 'Parrotfish', 'Grouper', 'Goatfish', 'Mullet',
    'Shark/Ray', 'Surgeonfish', 'Trevally'
  ];

  final _marketList = [
    'Malindi Market', 'Darajani Market', 'Mkokotoni Market',
    'Nungwi Market', 'Mahonda Market'
  ];

  Future<void> _fetchForecast() async {
    setState(() => _loading = true);
    try {
      final api = context.read<ApiService>();
      final data = await api.getForecast(_species, _market);
      if (mounted) {
        setState(() {
          _forecast = data;
          _hasData = true;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _weatherIcon(String weather) {
    switch (weather) {
      case 'Sunny': return '☀️';
      case 'Calm': return '🌤️';
      case 'Windy': return '💨';
      case 'Rainy': return '🌧️';
      case 'Rough': return '🌊';
      default: return '🌤️';
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    double avgPrice = 0;
    if (_hasData && _forecast.isNotEmpty) {
      double sum = 0;
      for (var f in _forecast) {
        sum += (f['predicted_price_tzs'] as num).toDouble();
      }
      avgPrice = sum / _forecast.length;
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: AppTheme.primaryBg,
          title: Text(
            lang.t('7-Day Forecast', 'Utabiri wa Siku 7'),
            style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Input Card
              Container(
                decoration: AppTheme.glassDecoration,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.cyanAccent.withValues(alpha: 0.2),
                                AppTheme.blueAccent.withValues(alpha: 0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.trending_up, color: AppTheme.cyanAccent, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          lang.t('AI Price Forecast', 'Utabiri wa Bei wa AI'),
                          style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0d1321),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _species,
                          isExpanded: true,
                          dropdownColor: AppTheme.cardBg,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          items: _speciesList.map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(s, style: const TextStyle(fontSize: 13)),
                          )).toList(),
                          onChanged: (v) => setState(() => _species = v!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0d1321),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _market,
                          isExpanded: true,
                          dropdownColor: AppTheme.cardBg,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          items: _marketList.map((m) => DropdownMenuItem(
                            value: m,
                            child: Text(m, style: const TextStyle(fontSize: 13)),
                          )).toList(),
                          onChanged: (v) => setState(() => _market = v!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _loading ? null : _fetchForecast,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.blueAccent, AppTheme.cyanAccent],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: _loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  lang.t('Get Forecast', 'Pata Utabiri'),
                                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Summary + Chart when data exists
              if (_hasData) ...[
                Row(
                  children: [
                    _summaryCard(lang.t('Avg Price', 'Bei Wastani'), 'TZS ${avgPrice.round()}', AppTheme.cyanAccent),
                    const SizedBox(width: 8),
                    _summaryCard(lang.t('Confidence', 'Uhakika'), '${((_forecast[0]['confidence'] ?? 0.85) * 100).round()}%', AppTheme.emeraldAccent),
                    const SizedBox(width: 8),
                    _summaryCard(lang.t('Season', 'Msimu'), _forecast[0]['season'] ?? '', AppTheme.amberAccent),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: AppTheme.glassDecoration,
                  padding: const EdgeInsets.all(16),
                  height: 250,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: Colors.white.withValues(alpha: 0.05),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                            getTitlesWidget: (value, meta) => Text(
                              '${value.toInt()}',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= _forecast.length) return const SizedBox();
                              final date = _forecast[value.toInt()]['date'].toString().substring(5);
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(date, style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(
                            _forecast.length,
                            (i) => FlSpot(i.toDouble(), (_forecast[i]['predicted_price_tzs'] as num).toDouble()),
                          ),
                          isCurved: true,
                          color: AppTheme.cyanAccent,
                          barWidth: 3,
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppTheme.cyanAccent.withValues(alpha: 0.1),
                          ),
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                              radius: 4,
                              color: AppTheme.cyanAccent,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _forecast.map<Widget>((f) {
                    final date = DateTime.parse(f['date']);
                    return SizedBox(
                      width: (MediaQuery.of(context).size.width - 44) / 4,
                      child: Container(
                        decoration: AppTheme.glassDecoration,
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Text('${date.day}/${date.month}', style: TextStyle(color: Colors.grey.shade500, fontSize: 9)),
                            Text(_weatherIcon(f['weather'] ?? 'Calm'), style: const TextStyle(fontSize: 16)),
                            Text(f['weather'] ?? '', style: TextStyle(color: Colors.grey.shade600, fontSize: 8)),
                            const SizedBox(height: 4),
                            Text(
                              'TZS ${f['predicted_price_tzs']}',
                              style: GoogleFonts.inter(color: AppTheme.cyanAccent, fontWeight: FontWeight.w700, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                            Text(f['season'] ?? '', style: TextStyle(color: Colors.grey.shade600, fontSize: 8)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ]),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }

  Widget _summaryCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: AppTheme.glassDecoration,
        child: Column(
          children: [
            Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 9)),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.inter(color: color, fontWeight: FontWeight.w700, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
