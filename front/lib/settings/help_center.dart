import 'package:flutter/material.dart';
import 'Get help with sfety issues/safety_&_trust.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();

  final Map<String, bool> _expandedItems = {
    'cancel_booking': false,
    'charged_stay': false,
    'updating_account': false,
    'reset_password': false,
  };

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
          'Help Center',
          style: TextStyle(
            color: Color(0xFF23130A),
            fontSize: 28,
            fontFamily: 'CormorantGaramond',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Text(
                    'How can we help you today?',
                    style: TextStyle(
                      color: Color(0xFF23130A),
                      fontSize: 24,
                      fontFamily: 'CormorantGaramond',
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Find answers to common questions about your\nAndalus journey.',
                    style: TextStyle(
                      color: Color(0xFF4F4540),
                      fontSize: 16,
                      fontFamily: 'HankenGrotesk',
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFFD3C3BD)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(
                        color: Color(0xFF2A1B12),
                        fontSize: 14,
                        fontFamily: 'HankenGrotesk',
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Search articles, guides, and policies...',
                        hintStyle: TextStyle(
                          color: Color(0xFF81756F99),
                          fontSize: 16,
                          fontFamily: 'HankenGrotesk',
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Color(0xFF9B8C7E),
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Category grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.2,
                    children: [
                      _CategoryCard(
                        icon: Icons.calendar_today_outlined,
                        title: 'Booking & Stays',
                      ),
                      _CategoryCard(
                        icon: Icons.home_outlined,
                        title: 'Hosting on Akrili',
                      ),
                      _CategoryCard(
                        icon: Icons.shield_outlined,
                        title: 'Account &\nSecurity',
                      ),
                      _CategoryCard(
                        icon: Icons.verified_user_outlined,
                        title: 'Safety & Trust',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SafetyTrustScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Booking & Stays FAQ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'BOOKING & STAYS',
                        style: TextStyle(
                          color: Color(0xFF81756F),
                          fontSize: 11,
                          fontFamily: 'HankenGrotesk',
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.44,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'View all',
                          style: TextStyle(
                            color: Color(0xFF006972),
                            fontSize: 14,
                            fontFamily: 'HankenGrotesk',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD3C3BD)),
                    ),
                    child: Column(
                      children: [
                        _FAQItem(
                          question: 'How do I cancel my booking?',
                          answer:
                              'You can cancel your booking from the Trips section in your account. Cancellation policies vary by host — check the listing for details before booking.',
                          isExpanded: _expandedItems['cancel_booking']!,
                          onTap: () => setState(() {
                            _expandedItems['cancel_booking'] =
                                !_expandedItems['cancel_booking']!;
                          }),
                          showDivider: true,
                        ),
                        _FAQItem(
                          question: 'When will I be charged for my stay?',
                          answer:
                              'Payment is processed at the time of booking confirmation. You\'ll receive a receipt by email immediately after the charge.',
                          isExpanded: _expandedItems['charged_stay']!,
                          onTap: () => setState(() {
                            _expandedItems['charged_stay'] =
                                !_expandedItems['charged_stay']!;
                          }),
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Account & Security FAQ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ACCOUNT & SECURITY',
                        style: TextStyle(
                          color: Color(0xFF81756F),
                          fontSize: 11,
                          fontFamily: 'HankenGrotesk',
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.54,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'View all',
                          style: TextStyle(
                            color: Color(0xFF006972),
                            fontSize: 14,
                            fontFamily: 'HankenGrotesk',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD3C3BD)),
                    ),
                    child: Column(
                      children: [
                        _FAQItem(
                          question: 'Updating your account info',
                          answer:
                              'Go to Profile > Personal Info to update your name, email, phone number, or address. Some changes may require identity verification.',
                          isExpanded: _expandedItems['updating_account']!,
                          onTap: () => setState(() {
                            _expandedItems['updating_account'] =
                                !_expandedItems['updating_account']!;
                          }),
                          showDivider: true,
                        ),
                        _FAQItem(
                          question: 'How to reset a forgotten password',
                          answer:
                              'Tap "Forgot password" on the login screen. We\'ll send a reset link to your registered email address. Check your spam folder if you don\'t see it.',
                          isExpanded: _expandedItems['reset_password']!,
                          onTap: () => setState(() {
                            _expandedItems['reset_password'] =
                                !_expandedItems['reset_password']!;
                          }),
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),

            // Still have questions - dark card
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A271D),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                child: Stack(
                  children: [
                    // Decorative icon bottom right
                    Positioned(
                      bottom: -8,
                      right: -4,
                      child: Icon(
                        Icons.support_agent_outlined,
                        size: 80,
                        color: Colors.white.withOpacity(0.07),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Still have questions?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontFamily: 'CormorantGaramond',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Our hospitality team is available 24/7 to assist with your journey across Algeria.',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 14,
                            fontFamily: 'HankenGrotesk',
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF006972),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 28, vertical: 14),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Contact Support',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontFamily: 'HankenGrotesk',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _CategoryCard({required this.icon, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD3C3BD)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF006972), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF2A1B12),
                  fontSize: 13,
                  fontFamily: 'HankenGrotesk',
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FAQItem extends StatelessWidget {
  final String question;
  final String answer;
  final bool isExpanded;
  final VoidCallback onTap;
  final bool showDivider;

  const _FAQItem({
    required this.question,
    required this.answer,
    required this.isExpanded,
    required this.onTap,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        question,
                        style: const TextStyle(
                          color: Color(0xFF2A1B12),
                          fontSize: 14,
                          fontFamily: 'HankenGrotesk',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: const Color(0xFF9B8C7E),
                      size: 20,
                    ),
                  ],
                ),
                if (isExpanded) ...[
                  const SizedBox(height: 10),
                  Text(
                    answer,
                    style: const TextStyle(
                      color: Color(0xFF4F4540),
                      fontSize: 13,
                      fontFamily: 'HankenGrotesk',
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 0.7,
            color: Color(0xFFD3C3BD),
          ),
      ],
    );
  }
}