import 'package:app/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DrawerApp extends StatelessWidget {
  const DrawerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.sidebarBackground,
      child: Column(
        children: [
          _HeadDrawer(),
          Divider() //TODO: trocar cor

        ],
      ),
    );
  }
}

class _HeadDrawer extends StatelessWidget {
  const new({
    super.key,
  });

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
            children: [
              Text(
                "Meu Caderno",
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(
                      color: AppColors.onSidebarBackground,
                      fontSize: MediaQuery.of(context).textScaler
                          .scale(16),
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
