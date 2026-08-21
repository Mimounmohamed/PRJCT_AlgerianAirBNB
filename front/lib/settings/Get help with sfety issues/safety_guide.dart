import 'package:flutter/material.dart';

class SafetyGuideScreen extends StatelessWidget {
  const SafetyGuideScreen({super.key});

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
          'Safety Guide',
          style: TextStyle(
            color: Color(0xFF23130A),
            fontSize:28,
            fontFamily: 'CormorantGaramond',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/images/safehousing.png',
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Text(
                    'Host with confidence',
                    style: TextStyle(
                      color: Color(0xFF23130A),
                      fontSize: 28,
                      fontFamily: 'CormorantGaramond',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Hosting in Algeria is about more than sharing\nspace; it\'s about sharing our heritage of\nhospitality. These guidelines ensure a secure\nexperience for you and your guests.',
                    style: TextStyle(
                      color: Color(0xFF4F4540),
                      fontSize: 17,
                      fontFamily: 'HankenGrotesk',
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Know your guest section
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFCF6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFD3C3BD)),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.person_search_outlined,
                                color: Color(0xFF006972), size: 22),
                            SizedBox(width: 10),
                            Text(
                              'Know your guest',
                              style: TextStyle(
                                color: Color(0xFF23130A),
                                fontSize: 24,
                                fontFamily: 'CormorantGaramond',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _GuideItem(
                          icon: Icons.verified_outlined,
                          iconColor: const Color(0xFF006972),
                          title: 'Verify ID',
                          description:
                              'Always ensure guests have completed\nAKRILI\'s identity verification process\nbefore confirming a booking.',
                        ),
                        const SizedBox(height: 16),
                        _GuideItem(
                          icon: Icons.star_outline,
                          iconColor: const Color(0xFF006972),
                          title: 'Read Reviews',
                          description:
                              'Check guest history and read\nfeedback from other hosts in the\nAlgerian community to build trust.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Set clear rules section
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFCF6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFD3C3BD)),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Color(0xFF006972),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.rule_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Set clear rules',
                              style: TextStyle(
                                color: Color(0xFF23130A),
                                fontSize: 24,
                                fontFamily: 'CormorantGaramond',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Well-defined expectations lead to better stays. Customize your house rules to reflect your local customs.',
                          style: TextStyle(
                            color: Color(0xFF4F4540),
                            fontSize: 15,
                            fontFamily: 'HankenGrotesk',
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Rule chips in a 2-column grid
                        Row(
                          children: [
                            Expanded(
                              child: _RuleChip(
                                icon: Icons.smoke_free_outlined,
                                label: 'No Smoking',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _RuleChip(
                                icon: Icons.pets_outlined,
                                label: 'No Pets',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _RuleChip(
                                icon: Icons.group_off_outlined,
                                label: 'No Extra Guests',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _RuleChip(
                                icon: Icons.nights_stay_outlined,
                                label: 'Quiet Hours',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Prepare your home - dark card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A1B12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.home_outlined,
                                color: Colors.white70, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Prepare your home',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontFamily: 'CormorantGaramond',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _DarkGuideItem(
                          icon: Icons.sensors_outlined,
                          title: 'Safety Sensors',
                          description:
                              'Install smoke and carbon monoxide detectors in every sleeping area.',
                        ),
                        const SizedBox(height: 16),
                        _DarkGuideItem(
                          icon: Icons.local_fire_department_outlined,
                          title: 'Emergency Gear',
                          description:
                              'Keep a fire extinguisher and a first-aid kit in an accessible location.',
                        ),
                        const SizedBox(height: 16),
                        _DarkGuideItem(
                          icon: Icons.contacts_outlined,
                          title: 'Local Contacts',
                          description:
                              'Post emergency numbers (Protection Civile: 14) and your phone number prominently.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Insurance & protection
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F4F4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xFF006972).withOpacity(0.3)),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.shield_outlined,
                                color: Color(0xFF006972), size: 22),
                            SizedBox(width: 10),
                            Text(
                              'Insurance & protection',
                              style: TextStyle(
                                color: Color(0xFF006972),
                                fontSize: 24,
                                fontFamily: 'CormorantGaramond',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'AKRILI Host Shield',
                          style: TextStyle(
                            color: Color(0xFF006972),
                            fontSize: 16,
                            fontFamily: 'HankenGrotesk',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Rest easy knowing every booking includes\nup to 1,000,000 DZD in property damage\nprotection and liability insurance tailored\nfor Algerian hospitality.',
                          style: TextStyle(
                            color: Color(0xFF006D77),
                            fontSize: 13,
                            fontFamily: 'HankenGrotesk',
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            
                            label: const Text(
                              'View Protection Details',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'HankenGrotesk',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            icon: const Icon(Icons.arrow_forward,
                                color: Colors.white, size: 16),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF006972),
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

                  // Footer
                  const Center(
                    child: Text(
                      'Still have questions about safety?',
                      style: TextStyle(
                        color: Color(0xFF4F4540),
                        fontSize: 15,
                        fontFamily: 'HankenGrotesk',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Visit Support Center',
                      style: TextStyle(
                        color: Color(0xFF006972),
                        fontSize: 16,
                        fontFamily: 'HankenGrotesk',
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFF006972),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const _GuideItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        const SizedBox(width: 12),
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
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  color: Color(0xFF4F4540),
                  fontSize: 13,
                  fontFamily: 'HankenGrotesk',
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DarkGuideItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _DarkGuideItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white70, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'HankenGrotesk',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                  fontFamily: 'HankenGrotesk',
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RuleChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _RuleChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF6),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFD3C3BD)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF006972), size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF2A1B12),
              fontSize: 13,
              fontFamily: 'HankenGrotesk',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}