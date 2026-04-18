import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart' as path;
import '../models/moment.dart';

class MomentService {
  final _supabase = Supabase.instance.client;

  /// 데이터 일시 조회 (타임아웃 방지용)
  Future<List<Moment>> fetchMoments() async {
    final response = await _supabase.from('moments').select().order('created_at');
    return (response as List).map((map) => Moment.fromMap(map, map['id'].toString())).toList();
  }

  /// Supabase DB(Table)에서 moments 목록을 실시간으로 가져옴
  Stream<List<Moment>> getMomentsStream() async* {
    List<Moment> lastData = [];

    // 1. 먼저 일반 조회로 데이터를 즉시 가져와서 지도를 띄웁니다
    try {
      final initialData = await _supabase.from('moments').select().order('created_at');
      lastData = (initialData as List).map((map) => Moment.fromMap(map, map['id'].toString())).toList();
      yield lastData;
    } catch (e) {
      print('Initial fetch error: $e');
    }

    // 2. 실시간 스트림 연결 및 에러 발생 시 재시도 루프
    while (true) {
      try {
        final stream = _supabase
            .from('moments')
            .stream(primaryKey: ['id'])
            .order('created_at')
            .map((data) {
          lastData = data.map((map) => Moment.fromMap(map, map['id'].toString())).toList();
          return lastData;
        });

        // yield* 는 스트림이 에러를 던지면 해당 에러를 전파하고 루프를 빠져나오게 됩니다 (catch 블록으로 이동)
        yield* stream;
        
        // 스트림이 정상적으로 종료된 경우 루프를 종료합니다.
        break; 
      } catch (e) {
        print('Realtime stream error: $e');
        
        // 타임아웃 등 일시적인 에러의 경우 마지막 데이터를 유지하며 재시도합니다.
        if (lastData.isNotEmpty) {
          yield lastData;
        }
        
        // 너무 자주 재시도하지 않도록 지연 시간을 둡니다.
        await Future.delayed(const Duration(seconds: 5));
        continue;
      }
    }
  }

  /// 영상 업로드 및 데이터베이스 등록
  Future<void> uploadMoment(String filePath, String userId) async {
    try {
      Position position = await getCurrentLocation();

      final file = File(filePath);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(filePath)}';
      final storagePath = 'moments/$userId/$fileName';
      
      await _supabase.storage.from('videos').upload(
        storagePath,
        file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      final String videoUrl = _supabase.storage.from('videos').getPublicUrl(storagePath);

      await _supabase.from('moments').insert({
        'userid': userId,
        'videourl': videoUrl,
        'latitude': position.latitude,
        'longitude': position.longitude,
      });
    } catch (e) {
      print('Error uploading moment to Supabase: $e');
      rethrow;
    }
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Location services are disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return Future.error('Location permissions are denied');
    }
    
    return await Geolocator.getCurrentPosition();
  }
}
