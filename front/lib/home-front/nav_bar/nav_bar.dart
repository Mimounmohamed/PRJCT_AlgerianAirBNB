import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const NavBarDemo(),
    );
  }
}

class NavBarDemo extends StatefulWidget {
  const NavBarDemo({super.key});
  @override
  State<NavBarDemo> createState() => _NavBarDemoState();
}

class _NavBarDemoState extends State<NavBarDemo> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EA),
      body: Center(
        child: Text(
          'Screen ${_currentIndex + 1}',
          style: const TextStyle(fontSize: 24),
        ),
      ),
      bottomNavigationBar: AkriliNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class AkriliNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool hasUnreadMessages;

  const AkriliNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.hasUnreadMessages = false,
  });

  static const _white = Color(0xFFFFFCF6);
  static const _hostCircleSize = 56.0;
  static const _cornerRadius = 24.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: const BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(_cornerRadius),
              topRight: Radius.circular(_cornerRadius),
            ),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, -4),
                blurRadius: 12,
                spreadRadius: 0,
                color: Color(0x143A271D),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 64,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.explore_outlined,
                    activeIcon: Icons.explore,
                    label: 'Explore',
                    isActive: currentIndex == 0,
                    onTap: () => onTap(0),
                  ),
                  _NavItem(
                    icon: Icons.favorite_outline,
                    activeIcon: Icons.favorite,
                    label: 'Saved',
                    isActive: currentIndex == 1,
                    onTap: () => onTap(1),
                  ),
                  const SizedBox(width: 60),
                  _NavItem(
                    icon: Icons.chat_bubble_outline,
                    activeIcon: Icons.chat_bubble,
                    label: 'Messages',
                    isActive: currentIndex == 3,
                    onTap: () => onTap(3),
                    showBadge: hasUnreadMessages,
                  ),
                  _NavItem(
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: 'Profile',
                    isActive: currentIndex == 4,
                    onTap: () => onTap(4),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -_hostCircleSize / 2.5,
          left: 0,
          right: 0,
          child: _HostButton(
            isActive: currentIndex == 2,
            onTap: () => onTap(2),
          ),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool showBadge;

  static const _active = Color(0xFF006972);
  static const _inactive = Color(0xFF4F4540);

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  size: 26,
                  color: isActive ? _active : _inactive,
                ),
                if (showBadge)
                  Positioned(
                    top: -2,
                    right: -4,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? _active : _inactive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HostButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isActive;
  static const _active = Color(0xFF006972);
  static const _inactive = Color(0xFF4F4540);

  const _HostButton({required this.onTap, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: AkriliNavBar._hostCircleSize,
            height: AkriliNavBar._hostCircleSize,
            decoration: BoxDecoration(
              color: _active,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _active.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Host',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isActive ? _active : _inactive,
            ),
          ),
        ],
      ),
    );
  }
}