import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:travel_on_final/core/providers/navigation_provider.dart';
import 'package:travel_on_final/features/search/data/repositories/travel_repositories_impl.dart';
import 'package:travel_on_final/features/search/presentation/providers/travel_provider.dart';
import 'package:travel_on_final/firebase_options.dart';
import 'package:travel_on_final/route.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(
          create: (_) => TravelProvider(TravelRepositoryImpl()),  // 수정된 부분
        ),
        // 추가 provider들을 여기에 등록
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        child: MaterialApp.router(
          title: 'Travel On',
          debugShowCheckedModeBanner: false,
          routerConfig: goRouter,
        ),
      ),
    );
  }
}
