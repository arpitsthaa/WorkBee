import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:workbee/main.dart';

void main() {
  testWidgets('renders the WorkBee login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}
