import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:syaahi_app/core/constants/colors.dart';
import 'package:syaahi_app/core/constants/sizes.dart';

/// Navigation shell hosting four primary tab destinations.
///
/// Shell branches: Home(0), Discover(1), Heart(2), Profile(3).
/// Write is NOT a branch — it is pushed on top of the shell
/// to preserve PopScope, draft confirmation, and context.pop().
///
/// Responsive: bottom nav on mobile, navigation rail on wide screens.
class AppNavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppNavigationShell({super.key, required this.navigationShell});

  // Branch: 0=Home, 1=Discover, 2=Heart, 3=Profile
  // Visual: 0=Home, 1=Discover, 2=Write, 3=Heart, 4=Profile
  int get _selectedVisualIndex {
    switch (navigationShell.currentIndex) {
      case 0:
        return 0;
      case 1:
        return 1;
      case 2:
        return 3;
      case 3:
        return 4;
      default:
        return 0;
    }
  }

  void _onItemTapped(BuildContext context, int visualIndex) {
    if (visualIndex == 2) {
      context.push('/write');
      return;
    }
    final branchIndex = switch (visualIndex) {
      0 => 0,
      1 => 1,
      3 => 2,
      4 => 3,
      _ => 0,
    };
    navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          return _DesktopLayout(
            shell: navigationShell,
            selectedIndex: _selectedVisualIndex,
            onItemTapped: (i) => _onItemTapped(context, i),
          );
        }
        return _MobileLayout(
          shell: navigationShell,
          selectedIndex: _selectedVisualIndex,
          onItemTapped: (i) => _onItemTapped(context, i),
        );
      },
    );
  }
}

// ── Mobile Layout ──────────────────────────────────────────────────

class _MobileLayout extends StatelessWidget {
  final StatefulNavigationShell shell;
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const _MobileLayout({
    required this.shell,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: _BottomNav(
        selectedIndex: selectedIndex,
        onItemTapped: onItemTapped,
      ),
    );
  }
}

// ── Desktop Layout ─────────────────────────────────────────────────

class _DesktopLayout extends StatelessWidget {
  final StatefulNavigationShell shell;
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const _DesktopLayout({
    required this.shell,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _NavRail(
            selectedIndex: selectedIndex,
            onItemTapped: onItemTapped,
          ),
          const VerticalDivider(
            width: 1,
            thickness: 1,
            color: SyaahiColors.divider,
          ),
          Expanded(child: shell),
        ],
      ),
    );
  }
}

// ── Bottom Navigation (Mobile) ─────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const _BottomNav({
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: SyaahiColors.midnightBase,
        border: Border(
          top: BorderSide(color: SyaahiColors.divider, width: 0.5),
        ),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavButton(
              icon: selectedIndex == 0 ? Icons.home : Icons.home_outlined,
              label: 'Home',
              isSelected: selectedIndex == 0,
              onTap: () => onItemTapped(0),
            ),
            _NavButton(
              icon: selectedIndex == 1 ? Icons.explore : Icons.explore_outlined,
              label: 'Discover',
              isSelected: selectedIndex == 1,
              onTap: () => onItemTapped(1),
            ),
            _WriteButton(onTap: () => onItemTapped(2)),
            _NavButton(
              icon: selectedIndex == 3 ? Icons.favorite : Icons.favorite_outline,
              label: 'Heart',
              isSelected: selectedIndex == 3,
              onTap: () => onItemTapped(3),
            ),
            _NavButton(
              icon: selectedIndex == 4 ? Icons.person : Icons.person_outline,
              label: 'Profile',
              isSelected: selectedIndex == 4,
              onTap: () => onItemTapped(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? SyaahiColors.goldBase : SyaahiColors.textMuted;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SyaahiSizes.radiusMd),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WriteButton extends StatelessWidget {
  final VoidCallback onTap;

  const _WriteButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: SyaahiColors.goldBase,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: SyaahiColors.goldBase.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: const Icon(
              Icons.edit_outlined,
              color: SyaahiColors.midnightDark,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Navigation Rail (Desktop) ──────────────────────────────────────

class _NavRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const _NavRail({
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      backgroundColor: SyaahiColors.midnightBase,
      selectedIndex: selectedIndex,
      onDestinationSelected: onItemTapped,
      labelType: NavigationRailLabelType.all,
      selectedIconTheme: const IconThemeData(color: SyaahiColors.goldBase),
      unselectedIconTheme: const IconThemeData(color: SyaahiColors.textMuted),
      selectedLabelTextStyle: const TextStyle(
        color: SyaahiColors.goldBase,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelTextStyle: const TextStyle(
        color: SyaahiColors.textMuted,
        fontSize: 11,
      ),
      indicatorColor: SyaahiColors.goldBase.withValues(alpha: 0.12),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text('Home'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.explore_outlined),
          selectedIcon: Icon(Icons.explore),
          label: Text('Discover'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.edit_outlined),
          selectedIcon: Icon(Icons.edit),
          label: Text('Write'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.favorite_outline),
          selectedIcon: Icon(Icons.favorite),
          label: Text('Heart'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: Text('Profile'),
        ),
      ],
    );
  }
}
