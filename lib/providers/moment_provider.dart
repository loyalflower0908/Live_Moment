import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/moment_service.dart';
import '../models/moment.dart';

final momentServiceProvider = Provider((ref) => MomentService());

final momentsStreamProvider = StreamProvider<List<Moment>>((ref) {
  final service = ref.watch(momentServiceProvider);
  return service.getMomentsStream();
});
