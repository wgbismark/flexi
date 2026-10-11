import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flexiphones/shared_widgets/generalwidgets.dart';
import 'package:flutter/material.dart';

class AgentBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AgentBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var ch = Theme.of(context).colorScheme;
    return BottomNavigationBar(
      backgroundColor:
          AdaptiveTheme.of(context).mode.isDark
              ? ch.surface
              : const Color.fromARGB(255, 250, 252, 255),
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      enableFeedback: false,
      unselectedLabelStyle: ptstyle(size: 10, weight: 300),
      selectedLabelStyle: ptstyle(size: 11, weight: 400),
      selectedItemColor: ch.primary,
      unselectedItemColor: ch.onSurfaceVariant.withOpacity(0.7),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.storefront_outlined),
          label: 'Vendors',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_2_rounded),
          label: 'Share',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.payments_outlined),
          label: 'Earnings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Me',
        ),
      ],
    );
  }
}