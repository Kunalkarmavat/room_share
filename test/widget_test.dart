import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:room_share/core/widgets/google_logo.dart';

void main() {
  testWidgets('GoogleLogo renders without network', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: GoogleLogo(size: 24))),
    );
    expect(find.byType(GoogleLogo), findsOneWidget);
  });
}
