import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Supabase 초기화 (본인의 프로젝트 URL과 Anon Key로 교체하세요)
  await Supabase.initialize(
    url: 'YOUR_URL',
    anonKey: 'YOUR_ANON_KEY',
    realtimeClientOptions: const RealtimeClientOptions(
      timeout: Duration(seconds: 20),
    ),
  );
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '라이브 모먼트 맵',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const MapScreen(), // 시작 화면을 MapScreen으로 설정
    );
  }
}
