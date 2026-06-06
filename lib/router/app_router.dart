import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_texts.dart';
import '../features/converter/cubit/converter_cubit.dart';
import '../features/converter/cubit/converter_state.dart';
import '../features/converter/screens/converter_screen.dart';
import '../features/library/cubit/library_cubit.dart';
import '../features/library/screens/library_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/library',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => _ScaffoldWithNav(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/library',
              builder: (_, s) => const LibraryScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/converter',
              builder: (_, s) => const ConverterScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class _ScaffoldWithNav extends StatelessWidget {
  const _ScaffoldWithNav({required this.shell});
  final StatefulNavigationShell shell;

  void _onTabSelected(BuildContext context, int index) {
    // Reload library whenever user switches to it
    if (index == 0) {
      context.read<LibraryCubit>().load();
    }
    shell.goBranch(index);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConverterCubit, ConverterState>(
      // Auto-reload library the moment a book is published
      listenWhen: (_, current) => current is ConverterPublished,
      listener: (context, _) => context.read<LibraryCubit>().load(),
      child: Scaffold(
        body: shell,
        bottomNavigationBar: NavigationBar(
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primary.withValues(alpha: 0.15),
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (i) => _onTabSelected(context, i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.library_books_outlined),
              selectedIcon: Icon(Icons.library_books, color: AppColors.primary),
              label: AppTexts.navLibrary,
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_stories_outlined),
              selectedIcon: Icon(Icons.auto_stories, color: AppColors.primary),
              label: AppTexts.navConverter,
            ),
          ],
        ),
      ),
    );
  }
}
