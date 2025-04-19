import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:campus_buddy/app.dart';
import 'package:campus_buddy/domain/usecases/auth_usecase.dart';
import 'package:campus_buddy/presentation/blocs/auth/auth_bloc.dart';

void main() {
  testWidgets('App initializes without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      App(authUseCase: AuthUseCase()),
    );

    // Verify that the app starts with no errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
