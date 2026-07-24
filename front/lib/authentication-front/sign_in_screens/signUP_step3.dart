import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/app_bar.dart';
import '../widgets/signin_progressbar.dart';

class SignUpStep3 extends StatefulWidget {
  const SignUpStep3({super.key});

  @override
  State<SignUpStep3> createState() => _SignUpStep3State();
}

class _SignUpStep3State extends State<SignUpStep3> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  void _onBack() {
    Navigator.of(context).pop();
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _profileImage = File(picked.path));
    }
  }

  void _onCompleteProfile() {
    // TODO: submit the accumulated sign-up payload (step 1 + step 2 + photo)
    // to the backend, then navigate into the app (e.g. courtyard/home).
  }

  void _onSkip() {
    // TODO: submit the sign-up payload without a photo, then navigate into
    // the app (e.g. courtyard/home).
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: StepProgressIndicator(
                        currentStep: 3,
                        totalSteps: 3,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Center(
                      child: Text(
                        'Add a photo',
                        style: TextStyle(
                          fontFamily: 'CormorantGaramond',
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Center(
                      child: Text(
                        'Help hosts and guests get to know you.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B6B6B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFE4D9C4),
                                border: Border.all(
                                  color: const Color(0xFFD9CDB5),
                                  width: 1,
                                ),
                                image: DecorationImage(
                                  image: _profileImage != null
                                      ? FileImage(_profileImage!)
                                          as ImageProvider
                                      : const AssetImage(
                                          'assets/images/default_avatar.png',
                                        ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 6,
                              bottom: 6,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F4C4C),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFFBF3E7),
                                    width: 3,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'You can change this later',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B6B6B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onCompleteProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F4C4C),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Complete Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _onSkip,
                    child: const Text(
                      'Skip for now',
                      style: TextStyle(
                        color: Color(0xFF0F4C4C),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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