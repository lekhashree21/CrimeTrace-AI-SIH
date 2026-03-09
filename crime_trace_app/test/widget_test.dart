import 'package:flutter_test/flutter_test.dart';
import 'package:crime_trace_app/main.dart';

void main() {
  testWidgets('CrimeTrace AI test', (WidgetTester tester) async {
    await tester.pumpWidget(const CrimeTraceApp());
    expect(find.text('CrimeTrace AI'), findsOneWidget);
  });
}