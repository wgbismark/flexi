// lib/widgets/custom_bottom_nav_bar.dart

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flexiphones/shared_widgets/generalwidgets.dart';
import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final bool ofl;
  final Function(int) onTap;
  final List cartItems;

  /// TODO: backend not ready — this is driven by
  /// SharedProvider.isAgentAccount, which is currently hardcoded.
  /// Once the backend exposes a real "is this user an agent" flag,
  /// nothing here needs to change — just the getter it reads from.
  final bool showAgentTab;
  final VoidCallback? onAgentTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.cartItems,
    required this.ofl,
    this.showAgentTab = false,
    this.onAgentTap,
  });

  @override
  Widget build(BuildContext context) {
    var ch = Theme.of(context).colorScheme;
    double sz = 30;

    // Agent tab only ever shows for logged-in users.
    final bool includeAgentTab = showAgentTab && !ofl;
    // Index of the agent tab, once ofl's normal items are accounted for.
    final int agentTabIndex = ofl ? 3 : 5;

    return BottomNavigationBar(
      elevation: ofl ? 0 : null,
      backgroundColor:
          AdaptiveTheme.of(context).mode.isDark
              ? ch.surface
              : const Color.fromARGB(255, 250, 252, 255),
      currentIndex: currentIndex,
      onTap: (index) {
        if (includeAgentTab && index == agentTabIndex) {
          onAgentTap?.call();
          return;
        }
        onTap(index);
      },
      type: BottomNavigationBarType.fixed,
      enableFeedback: false,

      unselectedLabelStyle: ptstyle(size: 10, weight: 300),
      selectedLabelStyle: ptstyle(size: 11, weight: 400),
      selectedItemColor: ch.primary,
      unselectedItemColor: ch.onSurfaceVariant.withOpacity(0.7),
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, size: sz),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard, size: sz),
          label: 'Browse',
        ),
        BottomNavigationBarItem(
          icon: Badge(
            isLabelVisible: cartItems.isNotEmpty,
            alignment: Alignment.topRight,
            label: Text(
              cartItems.length.toString(),
              style: ptstyle(size: 12, weight: 200),
            ),
            child: Icon(Icons.shopping_cart, size: sz),
          ),
          label: 'Cart',
        ),
        if (!ofl) ...[
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long, size: sz),
            label: 'Order',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        if (includeAgentTab)
          BottomNavigationBarItem(
            icon: Icon(Icons.workspace_premium_outlined, size: sz),
            label: 'Agent',
          ),
      ],
    );
  }
}