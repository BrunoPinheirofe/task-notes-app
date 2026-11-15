import 'package:app/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  setUpAll(() async {
    Intl.defaultLocale = 'pt_BR';
    await initializeDateFormatting('pt_BR', null);
  });

  testWidgets('Renderiza Meu Caderno e exibe Visão Geral', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TaskApp());
    await tester.pumpAndSettle();

    expect(find.text('Meu Caderno'), findsWidgets);
    expect(find.text('Visão Geral'), findsOneWidget);
    expect(find.text('Progresso Geral'), findsOneWidget);
    expect(find.text('Próximos Prazos'), findsOneWidget);
    expect(find.text('Notas Fixadas'), findsOneWidget);
    expect(find.text('Tarefas Recentes'), findsOneWidget);
  });
}
