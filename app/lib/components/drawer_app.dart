import 'package:app/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DrawerApp extends StatelessWidget {
  DrawerApp({super.key});

  final routes = [
    {
      "route": "",
      "label": "Visão geral",
      "icon": Icon(LucideIcons.layoutDashboard200),
      "badge": "",
    },
    {
      "route": "",
      "label": "Tarefas",
      "icon": Icon(LucideIcons.checkSquare200),
      "badge": "",
    },
    {
      "route": "",
      "label": "Anotações",
      "icon": Icon(LucideIcons.fileText200),
      "badge": "",
    },
    {
      "route": "",
      "label": "Categorias",
      "icon": Icon(LucideIcons.tag200),
      "badge": "",
    },
    {
      "route": "",
      "label": "Relatórios",
      "icon": Icon(LucideIcons.barChart3200),
      "badge": "",
    },
    {
      "route": "",
      "label": "Conquistas",
      "icon": Icon(LucideIcons.trophy200),
      "badge": "",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.sidebarBackground,
      child: Column(
        children: [
          _HeadDrawer(),
          Divider(), //TODO: trocar cor
          Expanded(
            child: ListView.builder(
              itemCount: routes.length,
              itemBuilder: ((context, index) {
                Map<String, Object> route = routes[index];
                String label = route["label"] as String;
                Icon icon = route["icon"] as Icon;
                String? badge = route["badge"] as String;
                return _NavigationItemDrawer(
                  label: label,
                  icon: icon,
                  badge: badge,
                  selected: index == 1,
                );
              }),
            ),
          ),
          _FooterDrawer(),
        ],
      ),
    );
  }
}

class _HeadDrawer extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 10, left: 15),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.onSidebarPrimary,
              borderRadius: .circular(50),
            ),
            child: Icon(LucideIcons.bookOpen),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                "Meu Caderno",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.onSidebarBackground,
                  fontSize: MediaQuery.of(context).textScaler.scale(16),
                ),
              ),
              Text(
                "tarefas & notas",
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(color: AppColors.accentSidebar),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavigationItemDrawer extends StatelessWidget {
  _NavigationItemDrawer({
    required this.label,
    required this.icon,
    required this.selected,
    this.badge,
    super.key,
  });
  bool selected;
  String label;
  Icon icon;
  String? badge;

  @override
  Widget build(BuildContext context) {
    TextStyle? textStyle = Theme.of(context).textTheme.bodyLarge
        ?.copyWith(color: AppColors.onSidebarBackground);

    return Container(
      margin: EdgeInsets.all(10),
      decoration: selected
          ? BoxDecoration(
              color: const Color(
                0xFF3F3024,
              ), //TODO: adicionar cor em app_colors
              borderRadius: BorderRadius.circular(3),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF3F3024),
                  spreadRadius: 1,
                  blurRadius: 6,
                ),
              ],
            )
          : null,
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(icon.icon, color: AppColors.onSidebarBackground),
          SizedBox(width: 10),
          Text(label, style: textStyle),
          Spacer(),
          ?badge != null ? Text(badge!, style: textStyle) : null,
        ],
      ),
    );
  }
}

class _FooterDrawer extends StatelessWidget {
  const _FooterDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Column(
        crossAxisAlignment: .center,
        spacing: 24,
        children: [
          Row(
            spacing: 15,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: .circular(50),
                  color: Color(0xFF3F3024),
                ),
                child: Icon(
                  LucideIcons.user,
                  size: 16,
                  color: AppColors.onSidebarBackground,
                ),
              ),
              Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                    "nomedocabra@logado.com",
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: AppColors.onSidebarBackground),
                  ),
                  Text(
                    "logado",
                    style: Theme.of(context).textTheme.labelLarge
                        ?.copyWith(color: AppColors.accentSidebar),
                  ),
                ],
              ),
            ],
          ),
          Row(
            spacing: 12,
            children: [
              Icon(LucideIcons.logOut200, color: AppColors.onSidebarBackground),
              Text(
                "Sair",

                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(color: AppColors.onSidebarBackground),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
