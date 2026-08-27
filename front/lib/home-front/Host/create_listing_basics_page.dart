import 'package:flutter/material.dart';
import '../../../authentication-front/widgets/app_bar.dart'; // adjust path to match your project structure
import '../widgets/create_listing_pattern_background.dart'; // adjust path if you placed this elsewhere

/// Step 2 of the Create Listing wizard — basics (guests, bedrooms,
/// bathrooms). Currently holds its own local state; once a shared
/// listing-draft object exists, these values (and the propertyType
/// selected on the previous step) should be threaded through it instead.
class CreateListingBasicsPage extends StatefulWidget {
  final String propertyType;

  const CreateListingBasicsPage({super.key, required this.propertyType});

  @override
  State<CreateListingBasicsPage> createState() => _CreateListingBasicsPageState();
}

class _CreateListingBasicsPageState extends State<CreateListingBasicsPage> {
  static const Color _dark = Color(0xFF2A1B12);
  static const Color _teal = Color(0xFF006972);
  static const Color _muted = Color(0xFF8A7B6E);
  static const Color _border = Color(0xFFE7DCCB);

  int _guests = 4;
  int _bedrooms = 2;
  double _bathrooms = 1.5;

  static const int _minGuests = 1;
  static const int _minBedrooms = 0;
  static const double _minBathrooms = 0.5;

  Widget _counterRow({
    required String title,
    required String subtitle,
    required String valueLabel,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: _dark, fontSize: 20, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(color: _muted, fontSize: 15, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              _stepperButton(icon: Icons.remove, onTap: onDecrement),
              SizedBox(
                width: 36,
                child: Text(
                  valueLabel,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _dark, fontSize: 19, fontWeight: FontWeight.w700),
                ),
              ),
              _stepperButton(icon: Icons.add, onTap: onIncrement),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, color: _border),
      ],
    );
  }

  Widget _stepperButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          border: Border.fromBorderSide(BorderSide(color: _border)),
        ),
        child: Icon(icon, size: 16, color: _dark),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF3E7),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFBF3E7),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AkriliAppBar(
            title: 'AKRILI',
            onBack: () => Navigator.of(context).maybePop(),
          ),
        ),
      ),
      body: CreateListingPatternBackground(
        
        child: Column(
          
          children: [
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Share some basics about your place',
                      style: TextStyle(
                        color: _dark,
                        fontSize: 32,
                        fontFamily: 'CormorantGaramond',
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Help guests know what to expect when booking your Algerian escape.',
                      style: TextStyle(color: _muted, fontSize: 16, height: 1.4),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _counterRow(
                            title: 'Guests',
                            subtitle: 'MAXIMUM CAPACITY',
                            valueLabel: '$_guests',
                            onDecrement: () => setState(() {
                              if (_guests > _minGuests) _guests--;
                            }),
                            onIncrement: () => setState(() => _guests++),
                          ),
                          _counterRow(
                            title: 'Bedrooms',
                            subtitle: 'PRIVATE OR SHARED',
                            valueLabel: '$_bedrooms',
                            onDecrement: () => setState(() {
                              if (_bedrooms > _minBedrooms) _bedrooms--;
                            }),
                            onIncrement: () => setState(() => _bedrooms++),
                          ),
                          _counterRow(
                            title: 'Bathrooms',
                            subtitle: 'FULL OR HALF',
                            valueLabel: _bathrooms.toStringAsFixed(1),
                            showDivider: false,
                            onDecrement: () => setState(() {
                              if (_bathrooms > _minBathrooms) _bathrooms -= 0.5;
                            }),
                            onIncrement: () => setState(() => _bathrooms += 0.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 1.8,
                            child: Image.asset(
                              // TODO: replace with the actual filename once added
                              // under front/assets/images/ (same pattern as the
                              // intro page's showcase image).
                              'assets/images/authentic_stays.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(color: const Color(0xFFE7DCCB)),
                            ),
                          ),
                          Positioned(
                            left: 16,
                            bottom: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.55),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'AUTHENTIC STAYS',
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              decoration: const BoxDecoration(
                color: Color(0xFFFBF3E7),
                border: Border(top: BorderSide(color: _border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: const Text('Back', style: TextStyle(color: _muted, fontWeight: FontWeight.w600)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: push the Location step, carrying widget.propertyType
                      // plus _guests/_bedrooms/_bathrooms forward once the
                      // shared listing-draft object exists.
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _teal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    ),
                    child: const Text('Next', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}