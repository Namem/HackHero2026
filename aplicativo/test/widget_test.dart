import 'package:flutter_test/flutter_test.dart';
import 'package:vigilia/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const VigiliaApp());
  });
}
