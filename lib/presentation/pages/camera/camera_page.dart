import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../../data/datasource/local/clip_local_datasource.dart';
import '../../../data/repositories/clip_repository_impl.dart';
import '../../../domain/repositories/clip_repository.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isRecording = false;
  int _countdown = 3;
  Timer? _countdownTimer;
  ClipRepository? _clipRepository;

  @override
  void initState() {
    super.initState();
    _clipRepository = ClipRepositoryImpl(ClipLocalDatasource());
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.high,
    );

    _initializeControllerFuture = _controller!.initialize();
    setState(() {});

    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
      });
      if (_countdown == 0) {
        timer.cancel();
        _startRecording();
      }
    });
  }

  Future<void> _startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    await _controller!.startVideoRecording();
    setState(() => _isRecording = true);
  }

  Future<void> _stopRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (!_isRecording) return;

    final file = await _controller!.stopVideoRecording();

    if (_clipRepository != null) {
      await _clipRepository!.saveClip(file.path);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _initializeControllerFuture == null
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return GestureDetector(
                    onTap: _isRecording ? _stopRecording : null,
                    child: Stack(
                      children: [
                        Center(child: CameraPreview(_controller!)),

                        if (_countdown > 0)
                          Center(
                            child: Text(
                              '$_countdown',
                              style: const TextStyle(
                                fontSize: 96,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),

                        if (_isRecording)
                          Positioned(
                            top: MediaQuery.of(context).padding.top + 16,
                            left: 16,
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'REC',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }
              },
            ),
    );
  }
}