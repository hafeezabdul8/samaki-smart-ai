import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/language_provider.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<dynamic> _alerts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchAlerts();
  }

  Future<void> _fetchAlerts() async {
    try {
      final api = context.read<ApiService>();
      final alerts = await api.getAlerts();
      if (mounted) {
        setState(() {
          _alerts = alerts;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'red':
        return AppTheme.redAccent;
      case 'amber':
        return AppTheme.amberAccent;
      default:
        return AppTheme.emeraldAccent;
    }
  }

  String _statusLabel(String status, LanguageProvider lang) {
    switch (status) {
      case 'red':
        return lang.t('RESTRICTED', 'HAIRUHUSIWI');
      case 'amber':
        return lang.t('CAUTION', 'TAHADHARI');
      default:
        return lang.t('SUSTAINABLE', 'ENDELEVU');
    }
  }

  String _getIcon(String name) {
    if (name.contains('Tuna') || name.contains('Jodari')) return '🐟';
    if (name.contains('Parrot') || name.contains('Pono')) return '🐠';
    if (name.contains('Snapper') || name.contains('Changu')) return '🐡';
    if (name.contains('Sardine') || name.contains('Dagaa') || name.contains('Anchovy')) return '🐟';
    if (name.contains('King') || name.contains('Nguru')) return '👑';
    if (name.contains('Octopus') || name.contains('Pweza') || name.contains('Squid') || name.contains('Ngisi')) return '🐙';
    if (name.contains('Rabbit') || name.contains('Tasi')) return '🐰';
    if (name.contains('Lobster') || name.contains('Kamba')) return '🦞';
    if (name.contains('Grouper') || name.contains('Chewa')) return '🐟';
    if (name.contains('Sword') || name.contains('Nduaro')) return '⚔️';
    if (name.contains('Mackerel') || name.contains('Vibua')) return '🐟';
    if (name.contains('Barracuda') || name.contains('Mzia')) return '🐊';
    if (name.contains('Shark') || name.contains('Papa') || name.contains('Ray') || name.contains('Taa')) return '🦈';
    if (name.contains('Goat') || name.contains('Mkundaji')) return '🐐';
    if (name.contains('Surgeon') || name.contains('Puju') || name.contains('Kangaja')) return '🐠';
    if (name.contains('Mullet') || name.contains('Mkizi')) return '🐟';
    if (name.contains('Trevally') || name.contains('Kolekole') || name.contains('Karambisi')) return '🐟';
    if (name.contains('Sardine') || name.contains('Saradini')) return '🐟';
    return '🐟';
  }

  String _getName(dynamic species, LanguageProvider lang) {
    final isSwahili = lang.locale.languageCode == 'sw';
    if (isSwahili &&
        species['name_sw'] != null &&
        species['name_sw'].toString().isNotEmpty) {
      return species['name_sw'];
    }
    return (species['name_en'] ?? '').replaceAll(RegExp(r' *\([^)]*\)'), '');
  }

  String _getSubtitle(dynamic species, LanguageProvider lang) {
    final isSwahili = lang.locale.languageCode == 'sw';
    if (isSwahili) {
      return species['name_en'] ?? '';
    }
    return '🇹🇿 ${species['name_sw']}';
  }

  String _getNote(dynamic alert, LanguageProvider lang) {
    final note = alert['note']?.toString() ?? '';
    if (note.isEmpty) return '';

    final translations = {
      'Common reef fish. Sustainable catch. High market demand.':
          'Samaki wa kawaida wa miamba. Uvuvi endelevu. Mahitaji makubwa sokoni.',
      'Critical for reef health. Overfished. Consider Snapper as alternative.':
          'Muhimu kwa afya ya miamba. Wamevuliwa kupita kiasi. Fikiria Changu kama mbadala.',
      'Abundant. Sustainable catch. Popular in hotels and restaurants.':
          'Wapo wengi. Uvuvi endelevu. Maarufu katika hoteli na migahawa.',
      'High value. Monitor catch levels. Important for tourism sector.':
          'Thamani kubwa. Fuatilia viwango vya uvuvi. Muhimu kwa sekta ya utalii.',
      'Common in local markets. Stable population.':
          'Wanapatikana katika masoko ya ndani. Idadi imara.',
      'Reef fish. Sustainable. Good for local consumption.':
          'Samaki wa miamba. Endelevu. Nzuri kwa matumizi ya ndani.',
      'Coastal species. Abundant. Important for food security.':
          'Spishi za pwani. Wapo wengi. Muhimu kwa usalama wa chakula.',
      'Very abundant. Key food source and export product.':
          'Wapo wengi sana. Chanzo muhimu cha chakula na bidhaa ya kuuza nje.',
      'Pelagic species. Abundant. Good for local markets.':
          'Spishi za bahari kuu. Wapo wengi. Nzuri kwa masoko ya ndani.',
      'Pelagic fish. Stable population. Popular in local cuisine.':
          'Samaki wa bahari kuu. Idadi imara. Maarufu katika vyakula vya ndani.',
      'Reef predator. Monitor stock levels.':
          'Mwindaji wa miamba. Fuatilia viwango vya akiba.',
      'Popular export fish. High demand. Avoid catching juveniles.':
          'Samaki maarufu wa kuuza nje. Mahitaji makubwa. Epuka kuvua wadogo.',
      'Deep sea species. High value for export.':
          'Spishi za bahari kuu. Thamani kubwa kwa mauzo ya nje.',
      'High value pelagic fish. Monitor catch levels.':
          'Samaki wa bahari kuu wenye thamani kubwa. Fuatilia viwango vya uvuvi.',
      'Predatory fish. Seasonal migration.':
          'Samaki mwindaji. Uhamaji wa msimu.',
      'Protected species. Critical for marine ecosystem.':
          'Spishi zilizohifadhiwa. Muhimu kwa mfumo wa ikolojia ya baharini.',
      'Important for export. Seasonal limits apply.':
          'Muhimu kwa mauzo ya nje. Vipimo vya msimu vinatumika.',
      'High value export product. Premium pricing.':
          'Bidhaa ya thamani kubwa ya kuuza nje. Bei ya juu.',
      'Popular export fish. High demand. Avoid catching juveniles.':
          'Samaki maarufu wa kuuza nje. Mahitaji makubwa. Epuka kuvua wadogo.',
      'High value. Monitor catch levels.':
          'Thamani kubwa. Fuatilia viwango vya uvuvi.',
      'Important for export. Seasonal limits apply.':
          'Muhimu kwa mauzo ya nje. Vipimo vya msimu vinatumika.',
      'Abundant. Sustainable catch.':
          'Wapo wengi. Uvuvi endelevu unaruhusiwa.',
      'Very abundant. Key food source.':
          'Wapo wengi sana. Chanzo muhimu cha chakula.',
      'Farmed and wild. Good availability.':
          'Wafugwao na wa mwituni. Wanapatikana vizuri.',
      'Common reef fish. Sustainable.':
          'Samaki wa kawaida wa miamba. Endelevu.',
      'Critical for reef health. Overfished. Consider Changu as alternative.':
          'Muhimu kwa afya ya miamba. Wamevuliwa kupita kiasi. Fikiria Changu kama mbadala.',
    };

    final isSwahili = lang.locale.languageCode == 'sw';
    if (isSwahili && translations.containsKey(note)) {
      return translations[note]!;
    }
    return note;
  }

  String _getSectionTitle(LanguageProvider lang) {
    return lang.t('Conservation Alerts', 'Tahadhari za Uhifadhi');
  }

  String _getRestrictedCount(LanguageProvider lang) {
    final count = _alerts.where((a) => a['status'] == 'red').length;
    return '$count ${lang.t('Restricted', 'Zimezuiliwa')}';
  }

  String _getLoadingText(LanguageProvider lang) {
    return lang.t('Loading alerts...', 'Inapakia tahadhari...');
  }

  String _getEmptyText(LanguageProvider lang) {
    return lang.t('No alerts found', 'Hakuna tahadhari zilizopatikana');
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return RefreshIndicator(
      onRefresh: _fetchAlerts,
      color: AppTheme.cyanAccent,
      backgroundColor: AppTheme.cardBg,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.primaryBg,
            title: Text(
              _getSectionTitle(lang),
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700, color: Colors.white),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.redAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppTheme.redAccent.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _getRestrictedCount(lang),
                  style: GoogleFonts.inter(
                    color: AppTheme.redAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: _loading
                ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: AppTheme.cyanAccent),
                          const SizedBox(height: 12),
                          Text(
                            _getLoadingText(lang),
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  )
                : _alerts.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Text(
                            _getEmptyText(lang),
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final alert = _alerts[index];
                            final color = _statusColor(alert['status']);
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: AppTheme.glassDecoration.copyWith(
                                border: Border.all(
                                    color: color.withValues(alpha: 0.3)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          _getIcon(alert['name_en']),
                                          style: const TextStyle(fontSize: 32),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _getName(alert, lang),
                                                style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                _getSubtitle(alert, lang),
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: color.withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                                color: color
                                                    .withValues(alpha: 0.3)),
                                          ),
                                          child: Text(
                                            _statusLabel(alert['status'], lang),
                                            style: TextStyle(
                                              color: color,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (alert['note'] != null &&
                                        alert['note'].toString().isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.05),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: color
                                                  .withValues(alpha: 0.15)),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 2),
                                              child: Icon(
                                                color == AppTheme.redAccent
                                                    ? Icons.block
                                                    : color == AppTheme.amberAccent
                                                        ? Icons.warning_amber_rounded
                                                        : Icons.check_circle_outline,
                                                color: color,
                                                size: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                _getNote(alert, lang),
                                                style: TextStyle(
                                                  color: Colors.grey.shade400,
                                                  fontSize: 13,
                                                  height: 1.5,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: _alerts.length,
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}