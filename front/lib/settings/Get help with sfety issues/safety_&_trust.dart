import 'package:flutter/material.dart';

class SafetyTrustScreen extends StatefulWidget {
  const SafetyTrustScreen({super.key});

  @override
  State<SafetyTrustScreen> createState() => _SafetyTrustScreenState();
}

class _SafetyTrustScreenState extends State<SafetyTrustScreen> {
  final TextEditingController _issueController = TextEditingController();

  @override
  void dispose() {
    _issueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF6EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF6EF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2A1B12)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Safety & Trust',
          style: TextStyle(
            color: Color(0xFF2A1B12),
            fontSize: 16,
            fontFamily: 'HankenGrotesk',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFBF6EF),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Message Safety Specialist button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.message_outlined,
                  color: Color(0xFF006972),
                  size: 18,
                ),
                label: const Text(
                  'MESSAGE SAFETY SPECIALIST',
                  style: TextStyle(
                    color: Color(0xFF006972),
                    fontSize: 11,
                    fontFamily: 'HankenGrotesk',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF006972)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Typical response time: Under 15 minutes',
              style: TextStyle(
                color: Color(0xFF9B8C7E),
                fontSize: 12,
                fontFamily: 'HankenGrotesk',
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emergency Support section
            Row(
              children: const [
                Text(
                  '✳',
                  style: TextStyle(
                    color: Color(0xFFB5451B),
                    fontSize: 20,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Emergency Support',
                  style: TextStyle(
                    color: Color(0xFF2A1B12),
                    fontSize: 22,
                    fontFamily: 'CormorantGaramond',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Emergency card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD3C3BD)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'If you are in immediate danger or require urgent medical assistance, please contact local authorities first.',
                    style: TextStyle(
                      color: Color(0xFF4F4540),
                      fontSize: 14,
                      fontFamily: 'HankenGrotesk',
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Call Local Emergency
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.phone_outlined,
                          color: Colors.white, size: 18),
                      label: const Text(
                        'CALL LOCAL EMERGENCY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontFamily: 'HankenGrotesk',
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB5451B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Contact Akrili Safety Team
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.shield_outlined,
                          color: Colors.white, size: 18),
                      label: const Text(
                        'CONTACT AKRILI SAFETY TEAM',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontFamily: 'HankenGrotesk',
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A1B12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Safety Guides
            const Text(
              'Safety Guides',
              style: TextStyle(
                color: Color(0xFF2A1B12),
                fontSize: 22,
                fontFamily: 'CormorantGaramond',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD3C3BD)),
              ),
              child: Column(
                children: [
                  _SafetyGuideItem(
                    icon: Icons.lightbulb_outline,
                    iconColor: const Color(0xFF006972),
                    title: 'Safe hosting tips',
                    onTap: () {},
                    showDivider: true,
                  ),
                  _SafetyGuideItem(
                    icon: Icons.report_outlined,
                    iconColor: const Color(0xFFB5451B),
                    title: 'Reporting an incident',
                    onTap: () {},
                    showDivider: true,
                  ),
                  _SafetyGuideItem(
                    icon: Icons.lock_outline,
                    iconColor: const Color(0xFF2A1B12),
                    title: 'Privacy and security',
                    onTap: () {},
                    showDivider: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Report a problem
            const Text(
              'Report a problem',
              style: TextStyle(
                color: Color(0xFF2A1B12),
                fontSize: 22,
                fontFamily: 'CormorantGaramond',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD3C3BD)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Describe the issue label
                  const Text(
                    'DESCRIBE THE ISSUE',
                    style: TextStyle(
                      color: Color(0xFF4F4540),
                      fontSize: 11,
                      fontFamily: 'HankenGrotesk',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.54,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Text area
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBF6EF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFD3C3BD)),
                    ),
                    child: TextField(
                      controller: _issueController,
                      maxLines: 5,
                      style: const TextStyle(
                        color: Color(0xFF2A1B12),
                        fontSize: 14,
                        fontFamily: 'HankenGrotesk',
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Please provide as much detail as possible...',
                        hintStyle: TextStyle(
                          color: Color(0xFFB5A89E),
                          fontSize: 13,
                          fontFamily: 'HankenGrotesk',
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Upload photo/evidence
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBF6EF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFD3C3BD)),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined,
                              color: Color(0xFF9B8C7E), size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Upload photo/evidence',
                            style: TextStyle(
                              color: Color(0xFF9B8C7E),
                              fontSize: 13,
                              fontFamily: 'HankenGrotesk',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Maximum 5 photos. Supported formats: JPG, PNG.',
                    style: TextStyle(
                      color: Color(0xFFB5A89E),
                      fontSize: 11,
                      fontFamily: 'HankenGrotesk',
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Submit report button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A1B12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'SUBMIT REPORT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontFamily: 'HankenGrotesk',
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
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

class _SafetyGuideItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;
  final bool showDivider;

  const _SafetyGuideItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF2A1B12),
                      fontSize: 14,
                      fontFamily: 'HankenGrotesk',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF9B8C7E),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 0.7,
            color: Color(0xFFD3C3BD),
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }
}