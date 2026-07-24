import 'package:flutter/material.dart';
import '../widgets/app_bar.dart';
import '../widgets/signin_progressbar.dart';
import '../widgets/birthday_field.dart';
import '../widgets/wilaya_baladiya_selector.dart';
import 'signUP_step3.dart';

enum Gender { male, female, other }

class SignUpStep2 extends StatefulWidget {
  const SignUpStep2({super.key});

  @override
  State<SignUpStep2> createState() => _SignUpStep2State();
}

class _SignUpStep2State extends State<SignUpStep2> {
  Gender _selectedGender = Gender.male;
  DateTime? _birthday;
  String? _wilayaCode;
  String? _baladiya;
  final _fullAddressController = TextEditingController();

  @override
  void dispose() {
    _fullAddressController.dispose();
    super.dispose();
  }

  void _onBack() {
    Navigator.of(context).pop();
  }

  void _onContinue() {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => const SignUpStep3()),
  );
}

  Widget _genderOption(String label, Gender value) {
    final isSelected = _selectedGender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGender = value),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0F4C4C) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF3E7),
      appBar: AkriliAppBar(
        title: 'Andalus',
        onBack: _onBack,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: StepProgressIndicator(currentStep: 2, totalSteps: 3),
              ),
              const SizedBox(height: 16),
              const Text(
                'Almost there',
                style: TextStyle(
                  fontFamily: 'CormorantGaramond',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tell us a bit more about yourself to personalize your '
                'Algerian stay experience.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B6B6B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  'Gender',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF3E7),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFD9CDB5)),
                ),
                child: Row(
                  children: [
                    _genderOption('Male', Gender.male),
                    _genderOption('Female', Gender.female),
                    _genderOption('Other', Gender.other),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              BirthdayField(
                selectedDate: _birthday,
                onDateSelected: (date) => setState(() => _birthday = date),
              ),
              const SizedBox(height: 16),
              WilayaBaladiyaSelector(
                selectedWilayaCode: _wilayaCode,
                selectedBaladiya: _baladiya,
                onWilayaChanged: (code) => setState(() {
                  _wilayaCode = code;
                  _baladiya = null;
                }),
                onBaladiyaChanged: (baladiya) =>
                    setState(() => _baladiya = baladiya),
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      'Full Address',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _fullAddressController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Street name, building number, apartment...',
                      hintStyle: const TextStyle(color: Color(0xFFB8AE9C)),
                      suffixIcon: const Icon(
                        Icons.home_outlined,
                        color: Color(0xFFB0A48C),
                        size: 20,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFFBF3E7),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFD9CDB5)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFD9CDB5)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 1,
                      color: const Color(0xFF9FBFBD),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Journeys begin with a single step',
                      style: TextStyle(
                        fontFamily: 'CormorantGaramond',
                        fontStyle: FontStyle.italic,
                        fontSize: 24,
                        color: Color.fromARGB(255, 83, 163, 158),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F4C4C),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}