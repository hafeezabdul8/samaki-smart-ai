import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    _phoneCtrl.text = user?['phone'] ?? '';
    _locationCtrl.text = user?['location'] ?? '';
    _marketCtrl.text = user?['market'] ?? '';
    _hotelNameCtrl.text = user?['hotel_name'] ?? '';
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
        market: _marketCtrl.text,
        hotelName: _hotelNameCtrl.text,
      );

      auth.setUser(res);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang.t('Profile updated!', 'Wasifu umesasishwa!')),
            backgroundColor: AppTheme.emeraldAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.redAccent),
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
                      ),
                      child: Center(
                        child: Text(
                          (user?['username'] ?? '?')[0].toUpperCase(),
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
                    Text(
                      isFisherman ? '🎣 Fisherman' : '🏨 Hotel Buyer',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Edit form
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
                    _buildField(lang.t('Phone Number', 'Namba ya Simu'), _phoneCtrl, Icons.phone),
                    const SizedBox(height: 12),
                    _buildField(lang.t('Location / Area', 'Eneo / Mahali'), _locationCtrl, Icons.location_on),
                    const SizedBox(height: 12),
                    if (isFisherman)
                      _buildField(lang.t('Market', 'Soko'), _marketCtrl, Icons.store),
                    if (!isFisherman)
                      _buildField(lang.t('Hotel Name', 'Jina la Hoteli'), _hotelNameCtrl, Icons.business),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _saving ? null : _save,
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
                          child: _saving
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text(
                                  lang.t('Save Profile', 'Hifadhi Wasifu'),
                                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
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

  Widget _buildField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 18),
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
