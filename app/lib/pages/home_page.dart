import 'package:app/components/drawer_app.dart';
import 'package:app/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerApp(),
      appBar: AppBar(
        animateColor: true,
        actionsPadding: .only(right: 20),
        elevation: 1,
        shape: Border(
          bottom: BorderSide(
            color: AppColors.secondary.withAlpha(70),
            width: 1.5,
          ),
        ),
        actions: [
          InkWell(child: Icon(LucideIcons.bell, size: 20)),
        ], //TODO: mudar posicao
        title: Row(
          spacing: 12,
          mainAxisAlignment: .end,
          children: [
            Icon(
              LucideIcons.bookOpen,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
            Text(
              'Meu Caderno',
              style: TextStyle(
                fontFamily: 'Playfair Display',
                fontWeight: .bold,
                fontSize: MediaQuery.of(context).textScaler.scale(20),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        
      ),
    );
  }
}
