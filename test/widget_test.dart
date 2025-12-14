// This is a basic Flutter widget test.
import 'package:flutter_test/flutter_test.dart';
import 'package:cinematch/main.dart';

void main() {
  testWidgets('App should start', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CineMatchApp());

    // Verify that the app starts without errors
    expect(find.byType(CineMatchApp), findsOneWidget);
  });
}
