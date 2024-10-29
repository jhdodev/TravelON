// lib/route.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// auth
import 'package:travel_on_final/features/auth/presentation/screens/login_screen.dart';
import 'package:travel_on_final/features/auth/presentation/screens/signup_screen.dart';
// core
import 'package:travel_on_final/core/presentation/widgets/scaffold_with_bottom_nav.dart';
// chat
import 'package:travel_on_final/features/chat/presentation/screens/chat_list_screen.dart';
// search
import 'package:travel_on_final/features/search/domain/entities/travel_package.dart';
import 'package:travel_on_final/features/search/presentation/screens/add_package_screen.dart';
import 'package:travel_on_final/features/search/presentation/screens/detail_screens.dart';
import 'package:travel_on_final/features/search/presentation/screens/package_detail_screen.dart';
// home
import 'package:travel_on_final/features/home/presentation/screens/home_screen.dart';
// profile
import 'package:travel_on_final/features/profile/presentation/screens/profile_screen.dart';


final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return ScaffoldWithBottomNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) => const DetailScreen(),
        ),
        GoRoute(
          path: '/chat_list',
          builder: (context, state) => ChatListScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/add-package',
          builder: (context, state) => const AddPackageScreen(),
        ),
        GoRoute(
          path: '/package-detail/:id',
          builder: (context, state) {
            final package = state.extra as TravelPackage;
            return PackageDetailScreen(package: package);
          },
        ),
        // 로그인 관련 라우트
        GoRoute(
          path: '/login',
          builder: (context, state) => LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => SignupScreen(),
        ),
      ],
    ),
  ],
);
