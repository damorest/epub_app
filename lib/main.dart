import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart' show AppTheme;
import 'data/repositories/api_repository.dart';
import 'data/repositories/library_repository.dart';
import 'features/converter/cubit/converter_cubit.dart';
import 'features/library/cubit/library_cubit.dart';
import 'router/app_router.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => ApiRepository()),
        RepositoryProvider(create: (_) => LibraryRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (ctx) => ConverterCubit(ctx.read<ApiRepository>()),
          ),
          BlocProvider(
            create: (ctx) => LibraryCubit(ctx.read<LibraryRepository>()),
          ),
        ],
        child: MaterialApp.router(
          title: 'EPUB Converter',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          routerConfig: appRouter,
        ),
      ),
    );
  }
}
