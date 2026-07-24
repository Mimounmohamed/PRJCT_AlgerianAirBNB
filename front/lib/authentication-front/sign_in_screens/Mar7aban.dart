import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WelcomeHomeScreen extends StatelessWidget {
  final String userName;

  const WelcomeHomeScreen({super.key, this.userName = 'Anis'});

  void _onStartExploring(BuildContext context) {
    // TODO: navigate to the main explore/listings screen.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF3E7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF3E7),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'AKRILI',
          style: TextStyle(
            fontFamily: 'CormorantGaramond',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHero(context),
              const SizedBox(height: 28),
              _buildHeritageSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return SizedBox(
      height: 560,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          const DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/marhaban.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Darkening gradient so text stays readable over the photo
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.55, 1.0],
                colors: [
                  Colors.black.withOpacity(0.0),
                  Colors.black.withOpacity(0.15),
                  Colors.black.withOpacity(0.78),
                ],
              ),
            ),
          ),
          // Greeting + CTA
          Positioned(
            left: 24,
            right: 24,
            bottom: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Marhaban, $userName!',
                  style: const TextStyle(
                    fontFamily: 'CormorantGaramond',
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your journey into the heart of Algeria begins here. '
                  'Discover authentic stays that tell a story.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _onStartExploring(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F4C4C),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Start Exploring',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeritageSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/icons/Icon (3).svg',
            width: 26,
            height: 26,
            colorFilter: const ColorFilter.mode(
              Color(0xFFB5652B),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Handpicked Heritage',
            style: TextStyle(
              fontFamily: 'CormorantGaramond',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'From the winding alleys of the Casbah to the red sands of '
            'the Tassili, find homes that celebrate our culture.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Color(0xFF6B6B6B),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _categoryCard(
                  iconAsset: 'assets/icons/Icon (2).svg',
                  label: 'SAHARA',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _categoryCard(
                  iconAsset: 'assets/icons/Icon (1).svg',
                  label: 'ALGIERS',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _categoryCard({required String iconAsset, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF3E7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD9CDB5)),
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            iconAsset,
            width: 22,
            height: 22,
            colorFilter: const ColorFilter.mode(
              Color(0xFF0F4C4C),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}