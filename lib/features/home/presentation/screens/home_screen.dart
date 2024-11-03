// lib/features/home/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:travel_on_final/features/auth/presentation/providers/auth_provider.dart';
import 'package:travel_on_final/features/home/presentation/providers/home_provider.dart';
import 'package:travel_on_final/features/home/presentation/widgets/next_trip_card.dart';
import 'package:travel_on_final/features/home/presentation/widgets/travel_card.dart';
import 'package:travel_on_final/features/home/presentation/widgets/weather_slider.dart';
import 'package:travel_on_final/features/search/presentation/providers/travel_provider.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // build가 완료된 후 데이터 로드
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

    // 패키지 데이터 로드
    await travelProvider.loadPackages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Text(
          'TravelOn',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // D-Day 카운터
              const NextTripCard(),
              SizedBox(height: 20.h),

              // 날씨 정보
              const WeatherSlider(),
              SizedBox(height: 30.h),

              // 메뉴 그리드
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                mainAxisSpacing: 20.w,
                crossAxisSpacing: 20.w,
                children: [
                  _buildMenuItem(Icons.star, '여행꿀팁'),
                  _buildMenuItem(Icons.map_outlined, '코스가이드'),
                  _buildMenuItem(Icons.calendar_today, '일정만들기'),
                  _buildMenuItem(Icons.photo_camera, '여행갤러리'),
                  _buildMenuItem(Icons.wb_sunny, '생생날씨'),
                  _buildMenuItem(Icons.favorite_border, '추천여행지'),
                  _buildMenuItem(Icons.restaurant, '추천맛집'),
                  _buildMenuItem(Icons.location_on, '전국지도'),
                ],
              ),
              SizedBox(height: 30.h),

              // 하단 추천 섹션
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '지금 인기있는 여행코스는?',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Row(
                      children: [
                        const Text(
                          '더보기',
                          style: TextStyle(color: Colors.blueAccent),
                        ),
                        Icon(Icons.chevron_right, color: Colors.grey.shade600),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),

              // 가로 스크롤 되는 추천 이미지 카드
              Consumer<TravelProvider>(
                builder: (context, provider, child) {
                  final recentPackages = provider.recentPackages;

                  return SizedBox(
                    height: 200.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: recentPackages.length,
                      itemBuilder: (context, index) {
                        final package = recentPackages[index];
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
                                context.go('/package-detail/${package.id}',
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

  Widget _buildMenuItem(IconData icon, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: Colors.blue),
        ),
        SizedBox(height: 3.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey.shade800,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getRegionText(String region) {
    switch (region) {
      case 'seoul':
        return '서울';
      case 'incheon_gyeonggi':
        return '인천/경기';
      case 'gangwon':
        return '강원';
      case 'daejeon_chungnam':
        return '대전/충남';
      case 'chungbuk':
        return '충북';
      case 'gwangju_jeonnam':
        return '광주/전남';
      case 'jeonbuk':
        return '전북';
      case 'busan_gyeongnam':
        return '부산/경남';
      case 'daegu_gyeongbuk':
        return '대구/경북';
      case 'jeju':
        return '제주도';
      default:
        return '전체';
    }
  }
}
