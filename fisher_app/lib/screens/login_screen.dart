import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/auth_provider.dart';
import '../services/language_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  bool _showPassword = false;
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _role = 'fisherman';
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    final lang = context.read<LanguageProvider>();
    try {
      if (_isLogin) {
        await auth.login(_usernameCtrl.text, _passwordCtrl.text);
      } else {
        await auth.register(
          _usernameCtrl.text,
          _phoneCtrl.text,
          _passwordCtrl.text,
          _role,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang.t('Registration successful! Please sign in.', 'Usajili umefanikiwa! Tafadhali ingia.')),
            backgroundColor: AppTheme.emeraldAccent,
          ),
        );
        setState(() => _isLogin = true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang.t('Login failed. Check credentials.', 'Kuingia kumeshindwa. Angalia taarifa.')),
          backgroundColor: AppTheme.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0a0f1e), Color(0xFF0d1321)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Language Toggle
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => lang.toggle(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🇹🇿', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(
                                lang.locale.languageCode == 'en' ? 'EN' : 'SW',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Logo
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.blueAccent, AppTheme.cyanAccent],
                        ),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.blueAccent.withValues(alpha: 0.3),
                            blurRadius: 40,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.waves, color: Colors.white, size: 48),
                    ),
                    const SizedBox(height: 24),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.white, Color(0xFF93C5FD)],
                      ).createShader(bounds),
                      child: Text(
                        lang.t('Samaki Smart AI', 'Samaki Smart AI'),
                        style: GoogleFonts.inter(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      lang.t("Empowering Zanzibar's Fisherfolk", 'Kuwasaidia Wavuvi wa Zanzibar'),
                      style: GoogleFonts.inter(color: Colors.blueGrey.shade300, fontSize: 14),
                    ),
                    const SizedBox(height: 40),
                    // Auth Card
                    Container(
                      decoration: AppTheme.glassDecoration,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.03),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _isLogin = true),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      decoration: BoxDecoration(
                                        color: _isLogin ? AppTheme.blueAccent : Colors.transparent,
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: _isLogin
                                            ? [BoxShadow(color: AppTheme.blueAccent.withValues(alpha: 0.3), blurRadius: 10)]
                                            : null,
                                      ),
                                      child: Text(
                                        lang.t('Sign In', 'Ingia'),
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          color: _isLogin ? Colors.white : Colors.grey.shade500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _isLogin = false),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      decoration: BoxDecoration(
                                        color: !_isLogin ? const Color(0xFF7C3AED) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: !_isLogin
                                            ? [BoxShadow(color: const Color(0xFF7C3AED).withValues(alpha: 0.3), blurRadius: 10)]
                                            : null,
                                      ),
                                      child: Text(
                                        lang.t('Register', 'Jiandikishe'),
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          color: !_isLogin ? Colors.white : Colors.grey.shade500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            controller: _usernameCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration(lang.t('Username', 'Jina la mtumiaji'), Icons.person, null),
                          ),
                          if (!_isLogin) ...[
                            const SizedBox(height: 16),
                            TextField(
                              controller: _phoneCtrl,
                              style: const TextStyle(color: Colors.white),
                              decoration: _inputDecoration(lang.t('Phone (10 digits)', 'Simu (tarakimu 10)'), Icons.phone, null),
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            ),
                          ],
                          const SizedBox(height: 16),
                          TextField(
                            controller: _passwordCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration(
                              lang.t('Password', 'Nywila'),
                              Icons.lock,
                              IconButton(
                                icon: Icon(
                                  _showPassword ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.grey.shade500,
                                  size: 20,
                                ),
                                onPressed: () => setState(() => _showPassword = !_showPassword),
                              ),
                            ),
                            obscureText: !_showPassword,
                          ),
                          if (!_isLogin) ...[
                            const SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF0d1321),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _role,
                                  dropdownColor: AppTheme.cardBg,
                                  style: const TextStyle(color: Colors.white),
                                  items: [
                                    DropdownMenuItem(
                                      value: 'fisherman',
                                      child: Text(lang.t('🎣 Fisherman', '🎣 Mvuvi')),
                                    ),
                                    DropdownMenuItem(
                                      value: 'hotel_buyer',
                                      child: Text(lang.t('🏨 Hotel Buyer', '🏨 Mnunuzi wa Hoteli')),
                                    ),
                                  ],
                                  onChanged: (val) => setState(() => _role = val!),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          Consumer<AuthProvider>(
                            builder: (context, auth, _) {
                              return GestureDetector(
                                onTap: auth.loading ? null : _submit,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: _isLogin
                                          ? [AppTheme.blueAccent, AppTheme.cyanAccent]
                                          : [const Color(0xFF7C3AED), const Color(0xFF9333EA)],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (_isLogin ? AppTheme.blueAccent : const Color(0xFF7C3AED))
                                            .withValues(alpha: 0.3),
                                        blurRadius: 15,
                                      ),
                                    ],
                                  ),
                                  child: auth.loading
                                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : Text(
                                          _isLogin ? lang.t('Sign In', 'Ingia') : lang.t('Create Account', 'Fungua Akaunti'),
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16),
                                        ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('© 2026 Samaki Smart AI • SUZA', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon, Widget? suffix) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade600),
      prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 20),
      suffixIcon: suffix,
      counterText: '',
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.03),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.cyanAccent),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}