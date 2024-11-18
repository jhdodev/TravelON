import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/datasources/tourism_density_api.dart';
import '../../data/models/tourism_density_model.dart';

class TourismDensityWidget extends StatefulWidget {
  const TourismDensityWidget({super.key});

  @override
  State<TourismDensityWidget> createState() => _TourismDensityWidgetState();
}

class _TourismDensityWidgetState extends State<TourismDensityWidget> {
  final _api = TourismDensityApi();
  List<TourismDensityModel> allSpots = [];
  List<TourismDensityModel> filteredSpots = [];
  bool isLoading = true;
  String selectedRegion = '전체';

  final List<String> regions = ['전체', '서울', '부산', '제주', '강원', '경주', '인천', '대구'];

  @override
  void initState() {
    super.initState();
    fetchHotSpots();
  }

  Future<void> fetchHotSpots() async {
    setState(() => isLoading = true);
    try {
      final spots = await _api.getTourismDensity();
      setState(() {
        allSpots = spots;
        filterSpots();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('데이터를 불러오는데 실패했습니다: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void filterSpots() {
    setState(() {
      filteredSpots = selectedRegion == '전체'
          ? List.from(allSpots)
          : allSpots.where((spot) => spot.location == selectedRegion).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '실시간 인기 관광지',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: fetchHotSpots,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildRegionFilter(),
          SizedBox(height: 16.h),
          _buildSpotsList(),
        ],
      ),
    );
  }

  Widget _buildRegionFilter() {
    return SizedBox(
      height: 35.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: regions.length,
        itemBuilder: (context, index) => _buildRegionChip(regions[index]),
      ),
    );
  }

  Widget _buildRegionChip(String region) {
    final isSelected = selectedRegion == region;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRegion = region;
          filterSpots();
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        margin: EdgeInsets.only(right: 8.w),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          region,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSpotsList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredSpots.isEmpty) {
      return Center(
        child: Column(
          children: [
            SizedBox(height: 20.h),
            Text(
              '$selectedRegion의 관광지 정보가 없습니다.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 120.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filteredSpots.length,
        itemBuilder: (context, index) => _buildSpotCard(filteredSpots[index]),
      ),
    );
  }

  Widget _buildSpotCard(TourismDensityModel spot) {
    return Container(
      width: 160.w,
      margin: EdgeInsets.only(right: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            spot.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.sp,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '${spot.location} · ${spot.category}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 8.h),
          _buildDensityIndicator(spot.density),
        ],
      ),
    );
  }

  Widget _buildDensityIndicator(double density) {
    final isHigh = density >= 80;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isHigh ? Icons.warning : Icons.people,
          color: isHigh ? Colors.red : Colors.blue,
          size: 16.sp,
        ),
        SizedBox(width: 4.w),
        Text(
          '혼잡도 ${density.toStringAsFixed(1)}%',
          style: TextStyle(
            color: isHigh ? Colors.red : Colors.blue,
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}