import 'package:app/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DrawerApp extends StatelessWidget {
  const DrawerApp({
    this.selectedIndex = 0,
    this.onSelectIndex,
    this.username = 'nomedocabra@logado.com',
    this.urgentBadgeCount = 0,
    this.onLogout,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int>? onSelectIndex;
  final String username;
  final int urgentBadgeCount;
  final VoidCallback? onLogout;

  static const List<({String label, IconData icon, bool showBadge})> _routes = [
    (
      label: 'Visão geral',
      icon: LucideIcons.layoutDashboard200,
      showBadge: true,
    ),
    (
      label: 'Tarefas',
      icon: LucideIcons.checkSquare200,
      showBadge: true,
    ),
    (
      label: 'Anotações',
      icon: LucideIcons.fileText200,
      showBadge: false,
    ),
    (
      label: 'Categorias',
      icon: LucideIcons.tag200,
      showBadge: false,
    ),
    (
      label: 'Relatórios',
      icon: LucideIcons.barChart3200,
      showBadge: false,
    ),
    (
      label: 'Conquistas',
      icon: LucideIcons.trophy200,
      showBadge: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.sidebarBackground,
      child: Column(
        children: [
          _HeadDrawer(urgentBadgeCount: urgentBadgeCount),
          const Divider(
            color: AppColors.sidebarBorder,
            thickness: 1,
            height: 1,
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _routes.length,
              itemBuilder: (context, index) {
                final item = _routes[index];
                final badge = item.showBadge && urgentBadgeCount > 0
                    ? '$urgentBadgeCount'
                    : null;
                return _NavigationItemDrawer(
                  label: item.label,
                  icon: item.icon,
                  badge: badge,
                  selected: index == selectedIndex,
                  onTap: () {
                    Navigator.of(context).pop();
                    onSelectIndex?.call(index);
                  },
                );
              },
            ),
          ),
          const Divider(
            color: AppColors.sidebarBorder,
            thickness: 1,
            height: 1,
          ),
          _FooterDrawer(username: username, onLogout: onLogout),
        ],
      ),
    );
  }
}

class _HeadDrawer extends StatelessWidget {
  const _HeadDrawer({required this.urgentBadgeCount});

  final int urgentBadgeCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 60, bottom: 16, left: 16, right: 16),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.onSidebarPrimary,
                  borderRadius: .circular(50),
                ),
                child: const Icon(
                  LucideIcons.bookOpen,
                  color: AppColors.sidebarActiveItem,
                ),
              ),
              if (urgentBadgeCount > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.destructive,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$urgentBadgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                'Meu Caderno',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.onSidebarBackground,
                  fontSize: MediaQuery.of(context).textScaler.scale(16),
                ),
              ),
              Text(
                'tarefas & notas',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.accentSidebar,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavigationItemDrawer extends StatelessWidget {
  const _NavigationItemDrawer({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final bool selected;
  final String label;
  final IconData icon;
  final String? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextStyle? textStyle = Theme.of(context).textTheme.bodyLarge
        ?.copyWith(
          color: selected
              ? AppColors.onSidebarAccent
              : AppColors.onSidebarBackground,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        );

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: selected
            ? BoxDecoration(
                color: AppColors.sidebarActiveItem,
                borderRadius: BorderRadius.circular(6),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.sidebarActiveItem,
                    spreadRadius: 1,
                    blurRadius: 6,
                  ),
                ],
              )
            : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Icon(
              icon,
              size: 19,
              color: selected
                  ? AppColors.onSidebarAccent
                  : AppColors.onSidebarBackground,
            ),
            const SizedBox(width: 12),
            Text(label, style: textStyle),
            const Spacer(),
            if (badge != null && badge!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.chartPriorityMedium,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    fontFamily: 'Lora',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FooterDrawer extends StatelessWidget {
  const _FooterDrawer({
    required this.username,
    this.onLogout,
  });

  final String username;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column(
        crossAxisAlignment: .center,
        spacing: 16,
        children: [
          Row(
            spacing: 12,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: .circular(50),
                  color: AppColors.sidebarActiveItem,
                ),
                child: const Icon(
                  LucideIcons.user,
                  size: 16,
                  color: AppColors.onSidebarBackground,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      username,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSidebarBackground,
                      ),
                    ),
                    Text(
                      'Logado',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.accentSidebar,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
              onLogout?.call();
            },
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: Row(
                spacing: 12,
                children: [
                  const Icon(
                    LucideIcons.logOut200,
                    size: 18,
                    color: AppColors.onSidebarBackground,
                  ),
                  Text(
                    'Sair',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.onSidebarBackground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
