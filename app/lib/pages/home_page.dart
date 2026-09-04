import 'package:app/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackGround, // Assuming this matches the beige background
      floatingActionButton: FloatingActionButton(
        clipBehavior: Clip.antiAlias,
        shape: const CircleBorder(),
        onPressed: () {
          print('fazer alguma coisa');
        },
        child: const Icon(LucideIcons.filePlus2300),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Barra Superior (Resetar Dados + Sino)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black26),
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(LucideIcons.rotateCcw, size: 16),
                    label: const Text("Resetar Dados"),
                  ),
                  const Icon(LucideIcons.bell, color: Colors.black87),
                ],
              ),
              const SizedBox(height: 30),
              
              // 2. Saudação
              Row(
                children: [
                  Text(
                    "Bom dia!",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFFA0522D), // Siena or primary red/brown color from mockup
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Cursive', // Tentar usar uma fonte cursiva se disponível
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(LucideIcons.sparkles, color: Color(0xFFA0522D), size: 20),
                ],
              ),
              
              const SizedBox(height: 4),
              
              // 3. Título Visão Geral
              Text(
                "Visão Geral",
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: 'Serif', // O mockup usa uma fonte serifa aqui
                ),
              ),
              
              const SizedBox(height: 8),
              
              // 4. Data
              Text(
                "quinta-feira, 3 de setembro de 2026", 
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[700],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // 5. Grid de Cards
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.9,
                  children: [
                    DashBoardCard(
                      title: 'Concluídas',
                      value: '1',
                      subtitle: 'de 1 tarefas',
                      icon: LucideIcons.checkSquare,
                      color: Colors.teal.shade700,
                    ),
                    DashBoardCard(
                      title: 'Em andamento',
                      value: '0',
                      subtitle: 'tarefas ativas',
                      icon: LucideIcons.clock,
                      color: Colors.orange.shade800,
                    ),
                    DashBoardCard(
                      title: 'Em atraso',
                      value: '0',
                      subtitle: 'precisam de atenção',
                      icon: LucideIcons.alertTriangle,
                      color: Colors.blueGrey.shade800,
                    ),
                    DashBoardCard(
                      title: 'Anotações',
                      value: '0',
                      subtitle: 'registros salvos',
                      icon: LucideIcons.fileText,
                      color: Colors.deepPurple.shade700,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashBoardCard extends StatelessWidget {
  const DashBoardCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    super.key,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackGround,
        border: Border.all(color: AppColors.cardBorder, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            // Círculo decorativo no fundo
            Positioned(
              bottom: -40.0,
              right: -40.0,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            
            // Conteúdo principal do card
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Linha superior com Título e Ícone
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: color, size: 22),
                      ),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Valor numérico
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Subtítulo
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
