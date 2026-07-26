import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/app_bar.dart';
import '../widgets/signin_progressbar.dart';
import '../../services/auth_service.dart';
import 'OTP_VerifyACC/Choose_method.dart';

class SignUpStep3 extends StatefulWidget {
  final String token;
  final String userName;
  const SignUpStep3({super.key, required this.token, required this.userName});

  @override
  State<SignUpStep3> createState() => _SignUpStep3State();
}

class _SignUpStep3State extends State<SignUpStep3> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

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

  void _onCompleteProfile() async {
    setState(() => _isLoading = true);

    try {
      String? imageUrl;

      if (_profileImage != null) {
        imageUrl = await AuthService.uploadToCloudinary(_profileImage!);
        await AuthService.updateProfilePhoto(
          token: widget.token,
          profilePhotoUrl: imageUrl,
        );
      }

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VerifyAccountScreen(
            token: widget.token,
            maskedPhone: '+213 XXX XX XX 88',
            maskedEmail: 'y***@domain.com',
          ),
        ),
      );
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSkip() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VerifyAccountScreen(
          token: widget.token,
          maskedPhone: '+213 XXX XX XX 88',
          maskedEmail: 'y***@domain.com',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF3E7),
      appBar: AkriliAppBar(
        title: 'AKRILI',
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
                                  color: const Color(0xFF006972),
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
                      onPressed: _isLoading ? null : _onCompleteProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006972),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
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
                    onTap: _isLoading ? null : _onSkip,
                    child: const Text(
                      'Skip for now',
                      style: TextStyle(
                        color: Color(0xFF006972),
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