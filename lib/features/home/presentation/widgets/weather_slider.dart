// lib/features/home/presentation/widgets/weather_slider.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:travel_on_final/features/home/presentation/providers/weather_provider.dart';

class WeatherSlider extends StatefulWidget {
  const WeatherSlider({super.key});

  @override
  State<WeatherSlider> createState() => _WeatherSliderState();
}

class _WeatherSliderState extends State<WeatherSlider> {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
    // 날씨 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().fetchWeather();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      final weatherList = context.read<WeatherProvider>().weatherList;
      if (weatherList.isNotEmpty) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % weatherList.length;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        if (weatherProvider.isLoading) {
          return Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (weatherProvider.error != null) {
          return Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: const Center(
              child: Text('날씨 정보를 불러오는데 실패했습니다.'),
            ),
          );
        }

        final weatherList = weatherProvider.weatherList;
        if (weatherList.isEmpty) {
          return Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: const Center(
              child: Text('날씨 정보가 없습니다.'),
            ),
          );
        }

        final currentWeather = weatherList[_currentIndex];

        return Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.5),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Row(
              key: ValueKey<int>(_currentIndex),
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currentWeather.city,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    _getWeatherIcon(currentWeather.condition),
                    SizedBox(width: 8.w),
                    Text(
                      '${currentWeather.temperature.toStringAsFixed(1)}°',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (currentWeather.precipitation > 0)
                      Text(
                        ' ${currentWeather.precipitation}mm ',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.blue,
                        ),
                      ),
                    Text(
                      '${currentWeather.windSpeed.toStringAsFixed(1)}m/s',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _getWeatherIcon(String condition) {
    switch (condition) {
      case '맑음':
        return Icon(Icons.wb_sunny, color: Colors.orange.shade400);
      case '구름많음':
        return Icon(Icons.cloud, color: Colors.grey.shade400);
      case '흐림':
        return Icon(Icons.cloud, color: Colors.grey.shade600);
      case '비':
        return Icon(Icons.umbrella, color: Colors.blue.shade400);
      case '비/눈':
        return Stack(
          children: [
            Icon(Icons.umbrella, color: Colors.blue.shade400),
            Icon(Icons.ac_unit, color: Colors.blue.shade100),
          ],
        );
      case '눈':
        return Icon(Icons.ac_unit, color: Colors.blue.shade100);
      case '소나기':
        return Icon(Icons.umbrella, color: Colors.blue.shade300);
      default:
        return Icon(Icons.wb_sunny, color: Colors.orange.shade400);
    }
  }
}
