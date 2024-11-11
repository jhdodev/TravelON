import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:travel_on_final/features/guide/presentation/provider/guide_ranking_provider.dart';

class GuideRankingScreen extends StatefulWidget {
  const GuideRankingScreen({Key? key}) : super(key: key);

  @override
  State<GuideRankingScreen> createState() => _GuideRankingScreenState();
}

class _GuideRankingScreenState extends State<GuideRankingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GuideRankingProvider>().loadRankings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('가이드 랭킹'),
      ),
      body: Consumer<GuideRankingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: provider.rankings.length,
            itemBuilder: (context, index) {
              final ranking = provider.rankings[index];
              return Card(
                margin: EdgeInsets.only(bottom: 16.h),
                child: ListTile(
                  onTap: () {
                    context.push(
                      '/guide-packages/${ranking.guideId}',
                      extra: ranking.guideName,
                    );
                  },
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.blue.shade100,
                    backgroundImage: ranking.profileImageUrl != null &&
                        ranking.profileImageUrl!.isNotEmpty
                        ? NetworkImage(ranking.profileImageUrl!)
                        : const AssetImage('assets/images/default_profile.png') as ImageProvider,
                  ),
                  title: Row(
                    children: [
                      Text(
                        ranking.guideName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    '총 ${ranking.totalReservations}건의 예약 / ${ranking.packageCount}개의 패키지',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  trailing: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: index == 0
                          ? Color(0XFFFDEF7A)
                          : index == 1
                          ? Color(0XFFE3E7EA)
                          : index == 2
                          ? Color(0XFFF69960)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      '${index + 1}위',
                      style: TextStyle(
                        color: index == 0
                            ? Colors.amber.shade900
                            : index == 1
                            ? Colors.grey.shade700
                            : index == 2
                            ? Colors.brown.shade700
                            : Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}