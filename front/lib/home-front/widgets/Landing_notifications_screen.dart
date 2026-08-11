import 'package:flutter/material.dart';
import '../../authentication-front/widgets/app_bar.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF3E7),
      appBar: AkriliAppBar(
        title: 'Notifications',
        onBack: () => Navigator.of(context).maybePop(),
      ),
      // TODO: build out the real notifications list later
      body: const Center(
        child: Text(
          'No notifications yet',
          style: TextStyle(fontSize: 14, color: Color(0xFF9A9188)),
        ),
      ),
    );
  }
}