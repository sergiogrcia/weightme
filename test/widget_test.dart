import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:weightme/app.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  testWidgets('La aplicación se inicia', (WidgetTester tester) async {
    await tester.pumpWidget(const WeightMeApp());
    await tester.pumpAndSettle();

    expect(find.text('Resumen'), findsOneWidget);
  });
}
