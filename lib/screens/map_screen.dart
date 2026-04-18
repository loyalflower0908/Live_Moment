import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:video_player/video_player.dart';
import '../providers/moment_provider.dart';
import '../models/moment.dart';
import 'record_screen.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  final LatLng _initialPosition = const LatLng(37.5665, 126.9780); // 서울 시청 중심

  @override
  Widget build(BuildContext context) {
    final momentsAsync = ref.watch(momentsStreamProvider);

    return Scaffold(
      body: Stack(
        children: [
          momentsAsync.when(
            data: (moments) => _buildMap(moments),
            loading: () => momentsAsync.hasValue
                ? _buildMap(momentsAsync.value!)
                : const Center(child: CircularProgressIndicator()),
            error: (err, stack) => momentsAsync.hasValue
                ? _buildMap(momentsAsync.value!)
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text('연결 오류: $err'),
                        ElevatedButton(
                          onPressed: () => ref.invalidate(momentsStreamProvider),
                          child: const Text('재시도'),
                        ),
                      ],
                    ),
                  ),
          ),
          if (momentsAsync.hasError && momentsAsync.hasValue)
            Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    ),
                    SizedBox(width: 10),
                    Text('실시간 연결 재시도 중...', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
            ),
          // 커스텀 내 위치 버튼 (왼쪽 하단)
          Positioned(
            bottom: 30,
            left: 20,
            child: FloatingActionButton(
              heroTag: 'my_location_btn',
              onPressed: _goToCurrentLocation,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.blue),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton.extended(
                heroTag: 'record_btn',
                onPressed: () => _onRecordButtonPressed(context),
                label: const Text('기록'),
                icon: const Icon(Icons.videocam),
                backgroundColor: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(List<Moment> moments) {
    final markers = moments.map((moment) {
      return Marker(
        markerId: MarkerId(moment.id),
        position: LatLng(moment.latitude, moment.longitude),
        onTap: () => _showVideoPlayer(context, moment.videoUrl),
      );
    }).toSet();

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _initialPosition,
        zoom: 14,
      ),
      onMapCreated: (controller) => _mapController = controller,
      markers: markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: false, // 기본 버튼 비활성화
    );
  }

  Future<void> _goToCurrentLocation() async {
    try {
      final position = await ref.read(momentServiceProvider).getCurrentLocation();
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          16,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('위치를 가져올 수 없습니다: $e')),
        );
      }
    }
  }

  Future<void> _onRecordButtonPressed(BuildContext context) async {
    final String? videoPath = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RecordScreen()),
    );

    if (videoPath != null && context.mounted) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        const SnackBar(content: Text('업로드 중...')),
      );
      try {
        await ref.read(momentServiceProvider).uploadMoment(videoPath, 'user_123');
        if (context.mounted) {
          messenger.showSnackBar(
            const SnackBar(content: Text('업로드 완료!')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          messenger.showSnackBar(
            SnackBar(content: Text('업로드 실패: $e')),
          );
        }
      }
    }
  }

  void _showVideoPlayer(BuildContext context, String videoUrl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (context) => _VideoPlayerWidget(videoUrl: videoUrl),
    );
  }
}

class _VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  const _VideoPlayerWidget({required this.videoUrl});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _controller.setVolume(1.0); // 소리 활성화
          _controller.play();
          _controller.setLooping(true);
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: _controller.value.isInitialized
          ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
          : const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}
