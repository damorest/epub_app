import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';
import '../features/converter/cubit/converter_cubit.dart';
import '../features/converter/cubit/converter_state.dart';
import '../features/converter/screens/converter_screen.dart';
import '../features/library/cubit/library_cubit.dart';
import '../features/library/screens/library_screen.dart';
import '../features/splash/splash_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/library',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => _ScaffoldWithNav(shell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/library', builder: (_, s) => const LibraryScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/converter', builder: (_, s) => const ConverterScreen()),
        ]),
      ],
    ),
  ],
);

class _ScaffoldWithNav extends StatefulWidget {
  const _ScaffoldWithNav({required this.shell});
  final StatefulNavigationShell shell;

  @override
  State<_ScaffoldWithNav> createState() => _ScaffoldWithNavState();
}

class _ScaffoldWithNavState extends State<_ScaffoldWithNav> {
  bool _showSplash = true;

  void _onTabSelected(BuildContext context, int index) {
    if (index == 0) context.read<LibraryCubit>().load();
    widget.shell.goBranch(index);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConverterCubit, ConverterState>(
      listenWhen: (_, current) => current is ConverterPublished,
      listener: (context, state) {
        final title = (state as ConverterPublished).job.title;
        context.read<LibraryCubit>().loadAfterPublish(title);
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: AppColors.bg,
            body: widget.shell,
            bottomNavigationBar: _GoldTabBar(
              currentIndex: widget.shell.currentIndex,
              onTap: (i) => _onTabSelected(context, i),
            ),
          ),
          if (_showSplash)
            SplashScreen(onDone: () => setState(() => _showSplash = false)),
        ],
      ),
    );
  }
}

class _GoldTabBar extends StatelessWidget {
  const _GoldTabBar({required this.currentIndex, required this.onTap});
  final int currentIndex;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.bg.withValues(alpha: 0),
            AppColors.ink,
          ],
          stops: const [0.0, 0.38],
        ),
      ),
      padding: EdgeInsets.fromLTRB(18, 9, 18, 8 + (bottom > 0 ? bottom : 22)),
      child: Row(
        children: [
          _Tab(
            icon: Icons.library_books_outlined,
            activeIcon: Icons.library_books,
            label: 'Бібліотека',
            active: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          const SizedBox(width: 8),
          _Tab(
            icon: Icons.auto_stories_outlined,
            activeIcon: Icons.auto_stories,
            label: 'Конвертер',
            active: currentIndex == 1,
            onTap: () => onTap(1),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          decoration: BoxDecoration(
            color: active ? AppColors.goldSoft : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                active ? activeIcon : icon,
                color: active ? AppColors.gold : AppColors.text3,
                size: 25,
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: AppTypography.tabLabel.copyWith(
                  color: active ? AppColors.gold : AppColors.text3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
