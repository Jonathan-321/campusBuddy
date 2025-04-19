import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'config/router/app_router.dart';
import 'domain/usecases/auth_usecase.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_event.dart';

/// The main app widget that configures the application
class App extends StatelessWidget {
  final AuthUseCase authUseCase;

  const App({
    super.key,
    required this.authUseCase,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(authUseCase)..add(AuthCheckRequested()),
      child: MaterialApp.router(
        title: 'Campus Buddy',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        darkTheme: ThemeData.dark().copyWith(
          useMaterial3: true,
          primaryColor: Colors.blue,
        ),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
