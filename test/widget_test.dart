import 'package:flutter_test/flutter_test.dart';
import 'package:todolist/main.dart';

void main() {
  testWidgets('TodoApp renders correctly smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TodoApp());
    await tester.pump();

    // Verify app title or core elements exist
    expect(find.text('My Tasks'), findsOneWidget);
  });
}
