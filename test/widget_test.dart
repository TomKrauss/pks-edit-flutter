import 'package:flutter_test/flutter_test.dart';
import 'package:pks_edit_flutter/main.dart';

void main() {
  testWidgets('Start application smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PksEditApplication(arguments: ["test.c"]));
  });
}