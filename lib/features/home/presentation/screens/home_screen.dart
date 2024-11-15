import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:travel_on_final/features/auth/presentation/providers/auth_provider.dart';
import 'package:travel_on_final/features/home/presentation/providers/home_provider.dart';
import 'package:travel_on_final/features/home/presentation/widgets/next_trip_card.dart';
import 'package:travel_on_final/features/home/presentation/widgets/travel_card.dart';
import 'package:travel_on_final/features/home/presentation/widgets/weather_slider.dart';
import 'package:travel_on_final/features/search/presentation/providers/travel_provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/navigation_provider.dart';
import '../../../../features/notification/presentation/screens/notification_center_screen.dart';
import '../../../../features/notification/presentation/providers/notification_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    final travelProvider = context.read<TravelProvider>();

    if (authProvider.currentUser != null) {
      await context
          .read<HomeProvider>()
          .loadNextTrip(authProvider.currentUser!.id);
    }

    await travelProvider.loadPackages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'app.name'.tr(),
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationCenterScreen(),
                    ),
                  );
                },
              ),
              Consumer<NotificationProvider>(
                builder: (context, provider, _) {
                  if (provider.unreadCount == 0) return const SizedBox.shrink();
                  return Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        provider.unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const NextTripCard(),
              SizedBox(height: 20.h),

              const WeatherSlider(),
              SizedBox(height: 30.h),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                mainAxisSpacing: 15.w,
                crossAxisSpacing: 15.w,
                // childAspectRatio를 조정하여 2줄 텍스트가 들어갈 공간 확보
                childAspectRatio: 0.9, // 1.0에서 0.9로 변경하여 세로 공간 확보
                children: [
                  _buildMenuItem(
                      Icons.star,
                      'menu.travel_tips'.tr(),
                      '/travel-tips'
                  ),
                  _buildMenuItem(
                      Icons.people,
                      'menu.guide_ranking'.tr(),
                      '/guide-ranking'
                  ),
                  _buildMenuItem(
                      Icons.favorite_border,
                      'menu.recommended_places'.tr(),
                      '/recommended-places'
                  ),
                  _buildMenuItem(
                      Icons.photo_camera,
                      'menu.travel_gallery'.tr(),
                      '/travel-gallery'
                  ),
                ],
              ),
              SizedBox(height: 30.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'home.popular_courses'.tr(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<NavigationProvider>().setIndex(1);
                    },
                    child: Row(
                      children: [
                        Text(
                          'common.see_more'.tr(),  // 여기를 확인
                          style: const TextStyle(color: Colors.blueAccent),
                        ),
                        Icon(Icons.chevron_right, color: Colors.grey.shade600),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),

              Consumer<TravelProvider>(
                builder: (context, provider, child) {
                  final popularPackages = provider.getPopularPackages();

                  return SizedBox(
                    height: 200.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: popularPackages.length,
                      itemBuilder: (context, index) {
                        final package = popularPackages[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            right: 16.w,
                            left: index == 0 ? 0 : 0,
                          ),
                          child: SizedBox(
                            width: 300.w,
                            child: TravelCard(
                              location: _getRegionText(package.region),
                              title: package.title,
                              imageUrl: package.mainImage ??
                                  'https://picsum.photos/300/200',
                              onTap: () {
                                context.push('/package-detail/${package.id}',
                                    extra: package);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, String route) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            if (route.isNotEmpty) {
              context.push(route);
            }
          },
          child: Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: Colors.blue, size: 20.r),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: Colors.grey.shade800,
          ),
          textAlign: TextAlign.center,
          maxLines: 2, // 1에서 2로 변경
          softWrap: true, // 자동 줄바꿈 활성화
        ),
      ],
    );
  }

  String _getRegionText(String region) {
    return 'regions.$region'.tr();
  }
}