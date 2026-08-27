import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../services/language_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _phoneCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _marketCtrl = TextEditingController();
  final _hotelNameCtrl = TextEditingController();
  bool _saving = false;
  bool _editing = false;
  String? _selectedMarket;

  final List<String> _markets = [
    'Malindi Market',
    'Darajani Market',
    'Mkokotoni Market',
    'Nungwi Market',
    'Mahonda Market',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    _phoneCtrl.text = user?['phone'] ?? '';
    _locationCtrl.text = user?['location'] ?? '';
    _marketCtrl.text = user?['market'] ?? '';
    _hotelNameCtrl.text = user?['hotel_name'] ?? '';
    _selectedMarket = user?['market'] ?? 'Malindi Market';
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _marketCtrl.dispose();
    _hotelNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final api = context.read<ApiService>();
      final auth = context.read<AuthProvider>();
      final lang = context.read<LanguageProvider>();
      api.token = auth.token;

      final res = await api.updateProfile(
        phone: _phoneCtrl.text,
        location: _locationCtrl.text,
        market: _selectedMarket ?? _marketCtrl.text,
        hotelName: _hotelNameCtrl.text,
      );

      auth.setUser(res);
      setState(() => _editing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang.t('Profile updated successfully!', 'Wasifu umesasishwa kikamilifu!')),
            backgroundColor: AppTheme.emeraldAccent,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final lang = context.read<LanguageProvider>();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang.t('Failed to update profile', 'Imeshindwa kusasisha wasifu')),
            backgroundColor: AppTheme.redAccent,
          ),
        );
      }
    }
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final user = context.watch<AuthProvider>().user;
    final isFisherman = user?['role'] == 'fisherman';

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: AppTheme.primaryBg,
          title: Text(
            lang.t('My Profile', 'Wasifu Wangu'),
            style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // User info card
              Container(
                decoration: AppTheme.glassDecoration,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.blueAccent, AppTheme.cyanAccent],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.blueAccent.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          (user?['username'] ?? '?').substring(0, 1).toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?['username'] ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.cyanAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.cyanAccent.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        isFisherman ? '🎣 ${lang.t('Fisherman', 'Mvuvi')}' : '🏨 ${lang.t('Hotel Buyer', 'Mnunuzi wa Hoteli')}',
                        style: TextStyle(color: AppTheme.cyanAccent, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // User Information Display Card
              Container(
                decoration: AppTheme.glassDecoration,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.t('My Information', 'Taarifa Zangu'),
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _infoRow(
                      Icons.person,
                      lang.t('Username', 'Jina la Mtumiaji'),
                      user?['username'] ?? '—',
                    ),
                    const SizedBox(height: 12),
                    _infoRow(
                      Icons.phone,
                      lang.t('Phone Number', 'Namba ya Simu'),
                      user?['phone'] ?? '—',
                    ),
                    const SizedBox(height: 12),
                    _infoRow(
                      Icons.location_on,
                      lang.t('Location / Area', 'Eneo / Mahali'),
                      user?['location'] ?? '—',
                    ),
                    if (isFisherman) ...[
                      const SizedBox(height: 12),
                      _infoRow(
                        Icons.store,
                        lang.t('Market', 'Soko'),
                        user?['market'] ?? '—',
                      ),
                    ],
                    if (!isFisherman) ...[
                      const SizedBox(height: 12),
                      _infoRow(
                        Icons.business,
                        lang.t('Hotel Name', 'Jina la Hoteli'),
                        user?['hotel_name'] ?? '—',
                      ),
                    ],
                    const SizedBox(height: 12),
                    _infoRow(
                      Icons.verified_user,
                      lang.t('Account Type', 'Aina ya Akaunti'),
                      user?['role'] ?? '—',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Edit Button
              if (!_editing)
                GestureDetector(
                  onTap: () => setState(() => _editing = true),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.blueAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.blueAccent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit, color: AppTheme.blueAccent, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          lang.t('Edit Profile', 'Hariri Wasifu'),
                          style: GoogleFonts.inter(
                            color: AppTheme.blueAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Edit form
              if (_editing)
                Container(
                  decoration: AppTheme.glassDecoration,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang.t('Edit Details', 'Hariri Taarifa'),
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildField(lang.t('Phone Number', 'Namba ya Simu'), _phoneCtrl, Icons.phone, TextInputType.phone, 10),
                      const SizedBox(height: 12),
                      _buildField(lang.t('Location / Area', 'Eneo / Mahali'), _locationCtrl, Icons.location_on, TextInputType.text, 100),
                      const SizedBox(height: 12),
                      if (isFisherman)
                        _buildMarketDropdown(lang),
                      if (!isFisherman)
                        _buildField(lang.t('Hotel Name', 'Jina la Hoteli'), _hotelNameCtrl, Icons.business, TextInputType.text, 200),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _editing = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  lang.t('Cancel', 'Ghairi'),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    color: Colors.grey.shade400,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: _saving ? null : _save,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppTheme.blueAccent, AppTheme.cyanAccent],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: _saving
                                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : Text(
                                          lang.t('Save', 'Hifadhi'),
                                          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildMarketDropdown(LanguageProvider lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lang.t('Market', 'Soko'),
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedMarket ?? 'Malindi Market',
              isExpanded: true,
              dropdownColor: AppTheme.cardBg,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              hint: Text(
                lang.t('Select Market', 'Chagua Soko'),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              icon: Icon(Icons.store, color: Colors.grey.shade500, size: 18),
              items: _markets.map((m) {
                return DropdownMenuItem<String>(
                  value: m,
                  child: Row(
                    children: [
                      const Text('🏪', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(m, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedMarket = val;
                  _marketCtrl.text = val ?? '';
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.blueAccent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.cyanAccent, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, TextInputType type, int maxLength) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          keyboardType: type,
          maxLength: maxLength,
          inputFormatters: type == TextInputType.phone
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 18),
            counterText: '',
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.03),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.cyanAccent),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}