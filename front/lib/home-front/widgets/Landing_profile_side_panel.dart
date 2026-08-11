import 'package:flutter/material.dart';

class ProfileSidePanel extends StatelessWidget {
  const ProfileSidePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFFBF3E7),
      width: MediaQuery.of(context).size.width * 0.8,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontFamily: 'CormorantGaramond',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Color(0xFF1A1A1A)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE3D8C0)),
            // TODO: build out the real side panel content later
            // (account info, settings, become a host, log out, etc.)
            const Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Profile panel content goes here',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Color(0xFF9A9188)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}