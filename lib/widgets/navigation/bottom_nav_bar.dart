import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavItem> items;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround, // Changed from spaceEvenly to spaceAround for better spacing
          children: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = index == currentIndex;
            final isAI = item.label == 'AI Assistant'; // Special handling for AI button

            return Flexible( // Changed from Expanded to Flexible
              child: GestureDetector(
                onTap: () => onTap(index),
                child: AnimatedContainer(
                  duration: AppConstants.shortAnimation,
                  padding: EdgeInsets.symmetric(
                    horizontal: isAI ? AppSizes.paddingSm : AppSizes.paddingXs, // More padding for AI
                    vertical: AppSizes.paddingSm,
                  ),
                  margin: EdgeInsets.symmetric(
                    horizontal: isAI ? 4 : 2, // More margin for AI
                    vertical: isAI ? 4 : 8, // Less vertical margin for AI to make it bigger
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: AppColors.purpleGradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : isAI && !isSelected
                            ? LinearGradient(
                                colors: [
                                  AppColors.purpleGradient.first.withValues(alpha: 0.2),
                                  AppColors.purpleGradient.last.withValues(alpha: 0.2),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                    borderRadius: BorderRadius.circular(isAI ? AppSizes.radiusLg : AppSizes.radiusMd),
                    border: isAI && !isSelected
                        ? Border.all(
                            color: AppColors.purpleGradient.first.withValues(alpha: 0.3),
                            width: 1,
                          )
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: AppConstants.shortAnimation,
                        child: Icon(
                          isSelected ? item.activeIcon : item.icon,
                          key: ValueKey(isSelected),
                          color: isSelected
                              ? Colors.white
                              : isAI
                                  ? AppColors.purpleGradient.first
                                  : AppColors.textSecondary,
                          size: isAI ? AppSizes.iconMd : AppSizes.iconSm, // Larger icon for AI
                        ),
                      ),
                      SizedBox(height: isAI ? 4 : 2), // More spacing for AI
                      Flexible(
                        child: Text(
                          item.label,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : isAI
                                    ? AppColors.purpleGradient.first
                                    : AppColors.textSecondary,
                            fontSize: isAI ? 10 : 9, // Larger font for AI
                            fontWeight: isSelected || isAI
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  const BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}

class AppBottomNavItems {
  static const List<BottomNavItem> items = [
    BottomNavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Dashboard',
      route: '/dashboard',
    ),
    BottomNavItem(
      icon: Icons.task_outlined,
      activeIcon: Icons.task,
      label: 'Tasks',
      route: '/tasks',
    ),
    BottomNavItem(
      icon: Icons.psychology_outlined,
      activeIcon: Icons.psychology,
      label: 'AI Assistant',
      route: '/ai-assistant',
    ),
    BottomNavItem(
      icon: Icons.folder_outlined,
      activeIcon: Icons.folder,
      label: 'Projects',
      route: '/projects',
    ),
    BottomNavItem(
      icon: Icons.emoji_events_outlined,
      activeIcon: Icons.emoji_events,
      label: 'Achievements',
      route: '/achievements',
    ),
    BottomNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
      route: '/profile',
    ),
  ];
}
