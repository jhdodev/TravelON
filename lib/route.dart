// lib/route.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
// auth
import 'package:travel_on_final/features/auth/presentation/screens/login_screen.dart';
import 'package:travel_on_final/features/auth/presentation/screens/signup_screen.dart';
import 'package:travel_on_final/features/auth/presentation/screens/reset_password_screen.dart';
// core
import 'package:travel_on_final/core/presentation/widgets/scaffold_with_bottom_nav.dart';
// chat
import 'package:travel_on_final/features/chat/presentation/screens/chat_list_screen.dart';
import 'package:travel_on_final/features/chat/presentation/screens/chat_screen.dart';
import 'package:travel_on_final/features/guide/presentation/screens/guide_packages_screen.dart';
import 'package:travel_on_final/features/guide/presentation/screens/guide_ranking_screen.dart';
import 'package:travel_on_final/features/chat/presentation/screens/guide_search_screen.dart';
// reservation
import 'package:travel_on_final/features/reservation/presentation/screens/reservation_calendar_screen.dart';
// search
import 'package:travel_on_final/features/search/domain/entities/travel_package.dart';
import 'package:travel_on_final/features/search/presentation/providers/travel_provider.dart';
import 'package:travel_on_final/features/search/presentation/screens/add_package_screen.dart';
import 'package:travel_on_final/features/search/presentation/screens/detail_screens.dart';
import 'package:travel_on_final/features/search/presentation/screens/package_detail_screen.dart';
// home
import 'package:travel_on_final/features/home/presentation/screens/home_screen.dart';
// profile
import 'package:travel_on_final/features/profile/presentation/screens/profile_screen.dart';
import 'package:travel_on_final/features/profile/presentation/screens/edit_packages_screen.dart';
import 'package:travel_on_final/features/profile/presentation/screens/guide_certification_screen.dart';
import 'package:travel_on_final/features/profile/presentation/screens/guide_reservation_screen.dart';
import 'package:travel_on_final/features/profile/presentation/screens/liked_packages_screen.dart';
import 'package:travel_on_final/features/profile/presentation/screens/my_packages_screen.dart';
import 'package:travel_on_final/features/profile/presentation/screens/reservation_screen.dart';
import 'package:travel_on_final/features/profile/presentation/screens/profile_edit_screen.dart';
// gallery
import 'package:travel_on_final/features/gallery/presentation/screens/travel_gallery_screen.dart';
import 'package:travel_on_final/features/gallery/presentation/screens/add_gallery_post_screen.dart';
import 'package:travel_on_final/features/gallery/presentation/screens/scrapped_posts_screen.dart';
import 'package:travel_on_final/features/gallery/presentation/screens/edit_gallery_post_screen.dart';
import 'package:travel_on_final/features/gallery/presentation/screens/gallery_search_screen.dart';
// review
import 'package:travel_on_final/features/review/presentation/screens/add_review_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: [
    ////////////////////////////////////////////////////////////////////////////////////
    //               ↓↓↓ 바텀 내비게이션 바가 필요 없는 화면 라우팅 ↓↓↓                  //
    ////////////////////////////////////////////////////////////////////////////////////
    GoRoute(
      path: '/add-package',
      builder: (context, state) => const AddPackageScreen(),
    ),
    GoRoute(
      path: '/package-detail/:id',
      builder: (context, state) {
        final package = state.extra as TravelPackage;
        return PackageDetailScreen(package: package, totalDays: 1,);
      },
    ),
    GoRoute(
      path: '/my-packages',
      builder: (context, state) => const MyPackagesScreen(),
    ),
    // TODO: 수정 화면용 라우트도 추가 필요
    GoRoute(
      path: '/edit-package/:id',
      builder: (context, state) {
        final package = state.extra as TravelPackage;
        return EditPackageScreen(package: package);
      },
    ),
    GoRoute(
      path: '/reservation/:packageId',
      builder: (context, state) {
        final package = state.extra as TravelPackage;
        return ReservationCalendarScreen(package: package);
      },
    ),
    GoRoute(
      path: '/reservations/guide',
      builder: (context, state) => const GuideReservationsScreen(),
    ),
    GoRoute(
      path: '/guide-certification',
      builder: (context, state) => const GuideCertificationScreen(),
    ),
    GoRoute(
      path: '/reservations/customer',
      builder: (context, state) => const CustomerReservationsScreen(),
    ),
    GoRoute(
      path: '/review/add',
      builder: (context, state) {
        final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
        return AddReviewScreen(
          packageId: extra['packageId'],
          packageTitle: extra['packageTitle'],
        );
      },
    ),
    GoRoute(
      path: '/guide-ranking',
      builder: (context, state) => const GuideRankingScreen(),
    ),
    GoRoute(
      path: '/guide-packages/:guideId',
      builder: (context, state) {
        final guideId = state.pathParameters['guideId']!;
        final guideName = state.extra as String;
        return GuidePackagesScreen(
          guideId: guideId,
          guideName: guideName,
        );
      },
    ),
    // 로그인 관련 라우트
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => SignupScreen(),
    ),
    GoRoute(
      path: '/reset_password',
      builder: (context, state) => const ResetPasswordScreen(),
    ),
    GoRoute(
      path: '/liked-packages',
      builder: (context, state) => const LikedPackagesScreen(),
    ),
    // 채팅 관련 라우트
    GoRoute(
      path: '/chat/:chatId',
      builder: (context, state) {
        final chatId = state.pathParameters['chatId']!;
        return ChatScreen(chatId: chatId);
      },
    ),
    GoRoute(
      path: '/guide_search',
      builder: (context, state) => const GuideSearchScreen(),
    ),
    GoRoute(
      path: '/profile/edit',
      builder: (context, state) => ProfileEditScreen(),
    ),
    ////////////////////////////////////////////////////////////////////////////////////
    //                ↓↓↓ 바텀 내비게이션 바가 필요한 화면 라우팅 ↓↓↓                    //
    ////////////////////////////////////////////////////////////////////////////////////
    ShellRoute(
      builder: (context, state, child) {
        return const ScaffoldWithBottomNavBar();
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
          builder: (context, state) => const ChatListScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/travel-gallery',
      builder: (context, state) => const TravelGalleryScreen(),
    ),
    GoRoute(
      path: '/add-gallery-post',
      builder: (context, state) => const AddGalleryPostScreen(),
    ),
    GoRoute(
      path: '/edit-gallery-post',
      builder: (context, state) {
        final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
        return EditGalleryPostScreen(
          postId: extra['postId'] as String,
          location: extra['location'] as String,
          description: extra['description'] as String,
          imageUrl: extra['imageUrl'] as String,
        );
      },
    ),
    GoRoute(
      path: '/scrapped-posts',
      builder: (context, state) => const ScrappedPostsScreen(),
    ),
    // 패키지 상세 페이지 라우트 추가
    GoRoute(
      path: '/package/:id',
      builder: (context, state) {
        final packageId = state.pathParameters['id']!;
        final package =
            context.read<TravelProvider>().getPackageById(packageId);
        if (package == null) {
          return const Scaffold(
            body: Center(
              child: Text('패키지를 찾을 수 없습니다.'),
            ),
          );
        }
        return PackageDetailScreen(package: package, totalDays: 1,);
      },
    ),
    // 기존 라우트 목록에 추가
    GoRoute(
      path: '/gallery-search',
      builder: (context, state) => const GallerySearchScreen(),
    ),
  ],
);
