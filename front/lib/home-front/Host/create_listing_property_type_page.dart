import 'package:flutter/material.dart';
import '../../../authentication-front/widgets/app_bar.dart'; // adjust path to match your project structure
import '../widgets/create_listing_pattern_background.dart'; // adjust path if you placed this elsewhere
import 'create_listing_basics_page.dart'; // adjust path if you placed this elsewhere
import '../../../models/listing_draft_model.dart'; // adjust path to match your project structure

class _PropertyTypeOption {
  final String label;
  final IconData icon;

  const _PropertyTypeOption({required this.label, required this.icon});
}

/// Step 1 of the Create Listing wizard — property type selection.
/// Matches the backend's Listing.propertyType enum exactly (see Listing.js):
/// Apartment, Hotel, Touristic Complex, Beach Cabin, House, Villa, Duplex,
/// Desert Cabin.
class CreateListingPropertyTypePage extends StatefulWidget {
  const CreateListingPropertyTypePage({super.key});

  @override
  State<CreateListingPropertyTypePage> createState() => _CreateListingPropertyTypePageState();
}

class _CreateListingPropertyTypePageState extends State<CreateListingPropertyTypePage> {
  static const Color _dark = Color(0xFF2A1B12);
  static const Color _teal = Color(0xFF006972);

  static const List<_PropertyTypeOption> _options = [
    _PropertyTypeOption(label: 'Apartment', icon: Icons.apartment),
    _PropertyTypeOption(label: 'Hotel', icon: Icons.hotel),
    _PropertyTypeOption(label: 'Touristic Complex', icon: Icons.holiday_village),
    _PropertyTypeOption(label: 'Beach Cabin', icon: Icons.beach_access),
    _PropertyTypeOption(label: 'House', icon: Icons.house),
    _PropertyTypeOption(label: 'Villa', icon: Icons.villa),
    _PropertyTypeOption(label: 'Duplex', icon: Icons.other_houses),
    _PropertyTypeOption(label: 'Desert Cabin', icon: Icons.terrain),
  ];

  String? _selected;

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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'What kind of place are you listing?',
                    style: TextStyle(
                      color: _dark,
                      fontSize: 26,
                      fontFamily: 'CormorantGaramond',
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Choose the category that best describes your home to help guests find you.',
                    style: TextStyle(color: Color(0xFF8A7B6E), fontSize: 15, height: 1.4),
                  ),
                  const SizedBox(height: 24),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _options.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.6,
                    ),
                    itemBuilder: (context, index) {
                      final option = _options[index];
                      final isSelected = _selected == option.label;

                      return GestureDetector(
                        onTap: () => setState(() => _selected = option.label),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? _teal : const Color(0xFFE7DCCB),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(option.icon, size: 32, color: isSelected ? _teal : _dark),
                              const Spacer(),
                              Text(
                                option.label,
                                style: TextStyle(
                                  color: isSelected ? _teal : _dark,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
            decoration: const BoxDecoration(
              color: Color(0xFFFBF3E7),
              border: Border(top: BorderSide(color: Color(0xFFE7DCCB))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  // Exit flow now returns all the way to the Host dashboard
                  // (the tab shell root) instead of just popping one step
                  // back to the Create Listing intro page.
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text('Exit flow', style: TextStyle(color: Color(0xFF8A7B6E), fontWeight: FontWeight.w600)),
                ),
                ElevatedButton(
                  onPressed: _selected == null
                      ? null
                      : () {
                          final draft = ListingDraft(
                            propertyType: _selected!,
                            guests: 1,
                            bedrooms: 0,
                            bathrooms: 0.5,
                          );
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CreateListingBasicsPage(draft: draft),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _teal,
                    disabledBackgroundColor: _teal.withOpacity(0.4),
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