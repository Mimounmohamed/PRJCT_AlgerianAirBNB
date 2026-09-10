import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/user_session.dart';
import '../services/base_client.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Toggles
  late bool _messagesPush;
  late bool _messagesEmail;
  late bool _remindersPush;
  late bool _promotionsEmail;
  late bool _policyEmail;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadFromSession();
  }

  void _loadFromSession() {
    final raw = UserSession.instance.rawUser;
    final ns = raw?['notificationSettings'] as Map<String, dynamic>? ?? {};
    _messagesPush   = ns['messages']       as bool? ?? true;
    _messagesEmail  = ns['helpUpdates']    as bool? ?? false;
    _remindersPush  = ns['bookingUpdates'] as bool? ?? true;
    _promotionsEmail = ns['promotions']    as bool? ?? false;
    _policyEmail    = ns['appUpdates']     as bool? ?? true;
  }

  String get _userEmail =>
      UserSession.instance.currentUser?.email ?? '';

  Future<void> _save() async {
    setState(() => _saving = true);
    final token = UserSession.instance.token;
    if (token == null) { setState(() => _saving = false); return; }

    try {
      await http.put(
        Uri.parse('${ApiConfig.baseUrl}/users/notification-settings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'messagesPush':    _messagesPush,
          'remindersPush':   _remindersPush,
          'promotionsEmail': _promotionsEmail,
        }),
      );

      // Update local session cache
      final raw = Map<String, dynamic>.from(UserSession.instance.rawUser ?? {});
      final ns = Map<String, dynamic>.from(raw['notificationSettings'] as Map<String, dynamic>? ?? {});
      ns['messages']       = _messagesPush;
      ns['bookingUpdates'] = _remindersPush;
      ns['promotions']     = _promotionsEmail;
      raw['notificationSettings'] = ns;
      UserSession.instance.setUser(
        UserSession.instance.currentUser!,
        raw: raw,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preferences saved'),
          backgroundColor: Color(0xFF006972),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF6EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF6EF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF23130A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Color(0xFF23130A),
            fontSize: 24,
            fontFamily: 'CormorantGaramond',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        color: const Color(0xFFFBF6EF),
        child: ElevatedButton(
          onPressed: _saving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF006972),
            disabledBackgroundColor: const Color(0xFF006972).withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: _saving
              ? const SizedBox(
                  height: 20, width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text(
                  'Update All Preferences',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontFamily: 'HankenGrotesk',
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose how you\'d like to be notified about your upcoming Algerian adventures and community \nupdates.',
              style: TextStyle(
                color: Color(0xFF4F4540),
                fontSize: 14,
                fontFamily: 'HankenGrotesk',
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),

            // Messages section
            _SectionHeader(icon: Icons.chat_bubble_outline, title: 'Messages'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color.fromRGBO(234, 221, 205, 0.30)),
              ),
              child: Column(
                children: [
                  _ToggleItem(
                    title: 'Push notifications',
                    subtitle: 'Directly to your mobile device',
                    value: _messagesPush,
                    onChanged: (val) => setState(() => _messagesPush = val),
                    showDivider: true,
                  ),
                  _ToggleItem(
                    title: 'Email',
                    subtitle: _userEmail.isNotEmpty
                        ? 'Sent to $_userEmail'
                        : 'No email on file',
                    value: _messagesEmail,
                    onChanged: (val) => setState(() => _messagesEmail = val),
                    showDivider: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Reminders section
            _SectionHeader(icon: Icons.notifications_outlined, title: 'Reminders'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color.fromRGBO(234, 221, 205, 0.30)),
              ),
              child: _ToggleItem(
                title: 'Push notifications',
                subtitle: 'Check-in times and trip updates',
                value: _remindersPush,
                onChanged: (val) => setState(() => _remindersPush = val),
                showDivider: false,
              ),
            ),
            const SizedBox(height: 28),

            // Promotions & Tips section
            _SectionHeader(icon: Icons.auto_awesome_outlined, title: 'Promotions & Tips'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color.fromRGBO(234, 221, 205, 0.30)),
              ),
              child: _ToggleItem(
                title: 'Email',
                subtitle: 'Exclusive deals and travel guides',
                value: _promotionsEmail,
                onChanged: (val) => setState(() => _promotionsEmail = val),
                showDivider: false,
              ),
            ),
            const SizedBox(height: 28),

            // Policy updates section
            _SectionHeader(icon: Icons.policy_outlined, title: 'Policy updates'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color.fromRGBO(234, 221, 205, 0.30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ToggleItem(
                    title: 'Email',
                    subtitle: 'Changes to terms and conditions',
                    value: _policyEmail,
                    onChanged: (val) => setState(() => _policyEmail = val),
                    showDivider: false,
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(
                      'IMPORTANT SERVICE UPDATES CANNOT BE DISABLED',
                      style: TextStyle(
                        color: Color(0xFF81756F),
                        fontSize: 11,
                        fontFamily: 'HankenGrotesk',
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF006972), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF2A1B12),
            fontSize: 16,
            fontFamily: 'HankenGrotesk',
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ToggleItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  const _ToggleItem({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF2A1B12),
                        fontSize: 14,
                        fontFamily: 'HankenGrotesk',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF9B8C7E),
                        fontSize: 12,
                        fontFamily: 'HankenGrotesk',
                      ),
                    ),
                  ],
                ),
              ),
              _CustomToggle(value: value, onChanged: onChanged),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, thickness: 0.7, color: Color(0xFFD3C3BD)),
      ],
    );
  }
}

class _CustomToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _CustomToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 51,
        height: 31,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9999),
          color: value ? const Color(0xFF006972) : const Color(0xFFEFE6D6),
          boxShadow: value
              ? [BoxShadow(color: const Color(0xFF006972).withValues(alpha: 0.30), blurRadius: 8)]
              : [],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(3),
            width: 25,
            height: 25,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.12), blurRadius: 4, offset: Offset(0, 1))],
            ),
          ),
        ),
      ),
    );
  }
}
