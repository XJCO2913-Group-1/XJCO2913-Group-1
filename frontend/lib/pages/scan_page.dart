import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart'; // Import main.dart to use global camera list

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isCameraPermissionGranted = false;
  bool _isCameraInitialized = false;
  bool _isPhotoPermissionGranted = false;
  final ImagePicker _imagePicker = ImagePicker();
  // Add zoom level variables
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentZoomLevel = 1.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestCameraPermission();
    _requestPhotoPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle camera when application lifecycle state changes
    final CameraController? cameraController = _cameraController;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _isCameraPermissionGranted = status.isGranted;
    });

    if (_isCameraPermissionGranted) {
      _initCamera();
    }
  }

  Future<void> _requestPhotoPermission() async {
    // 根据平台请求不同的权限
    PermissionStatus status;
    if (Platform.isAndroid) {
      // Android 13及以上使用READ_MEDIA_IMAGES，低版本使用READ_EXTERNAL_STORAGE
      if (await Permission.photos.request().isGranted) {
        status = PermissionStatus.granted;
      } else {
        status = await Permission.storage.request();
      }
    } else {
      status = await Permission.photos.request();
    }

    setState(() {
      _isPhotoPermissionGranted = status.isGranted;
    });
  }

  Future<void> _pickImageFromGallery() async {
    if (!_isPhotoPermissionGranted) {
      await _requestPhotoPermission();
      if (!_isPhotoPermissionGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('需要相册权限才能选择图片')),
        );
        return;
      }
    }

    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        // 这里可以处理选中的图片，例如解析二维码
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已选择图片: ${pickedFile.path}')),
        );
        // TODO: 添加二维码解析逻辑
      }
    } catch (e) {
      debugPrint('选择图片错误: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('选择图片失败')),
      );
    }
  }

  Future<void> _initCamera() async {
    if (cameras.isEmpty) {
      debugPrint('没有可用的相机');
      return;
    }

    // 使用前置摄像头（如果可用）
    final backCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    // 初始化相机控制器
    _cameraController = CameraController(
      backCamera,
      ResolutionPreset.max,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();

      // 获取相机支持的缩放范围
      _minAvailableZoom = await _cameraController!.getMinZoomLevel();
      _maxAvailableZoom = await _cameraController!.getMaxZoomLevel();

      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      debugPrint('相机初始化错误: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraPermissionGranted) {
      return _buildPermissionDeniedWidget();
    }
    if (Platform.isWindows) return const Center(child: Text('暂不支持Windows系统'));
    if (!_isCameraInitialized ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return _buildCameraPreview();
  }

  Widget _buildPermissionDeniedWidget() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '需要相机权限才能使用扫描功能',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _requestCameraPermission,
              child: const Text('授予权限'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImageFromGallery,
        backgroundColor: Colors.white.withOpacity(0.7),
        child: const Icon(Icons.photo_library, color: Colors.black87),
      ),
    );
  }

  Widget _buildCameraPreview() {
    final size = MediaQuery.of(context).size;
    // 计算适应屏幕的比例
    final screenAspectRatio = size.width / size.height;
    final cameraAspectRatio = _cameraController!.value.aspectRatio;

    // 计算比例以覆盖整个屏幕
    var scale = screenAspectRatio < cameraAspectRatio
        ? size.height / (size.width / cameraAspectRatio)
        : size.width / (size.height * cameraAspectRatio);
    scale -= 2;
    return Scaffold(
        body: SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 相机预览 - 添加手势检测器
          GestureDetector(
            onScaleStart: (details) {
              // 缩放开始时记录当前缩放级别
              _baseZoomLevel = _currentZoomLevel;
            },
            onScaleUpdate: (details) {
              // 更新缩放级别
              double newZoomLevel = _baseZoomLevel * details.scale;
              // 确保缩放级别在有效范围内
              newZoomLevel =
                  newZoomLevel.clamp(_minAvailableZoom, _maxAvailableZoom);

              if (newZoomLevel != _currentZoomLevel) {
                setState(() {
                  _currentZoomLevel = newZoomLevel;
                });
                _cameraController!.setZoomLevel(newZoomLevel);
              }
            },
            child: Transform.scale(
              scale: scale,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1 / cameraAspectRatio,
                  child: CameraPreview(_cameraController!),
                ),
              ),
            ),
          ),

          // 可以在这里添加其他UI元素，如扫描框、文字提示等
          Positioned(
            top: MediaQuery.of(context).size.height / 2 +
                125 +
                10, // 扫描框高度的一半(125) + 额外间距(10)
            left: 0,
            right: 0,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 50),
              child: const Text(
                'Put QR here',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          // 添加QR码扫描框 - 使用IgnorePointer确保不拦截触摸事件
          IgnorePointer(
            child: Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2.0),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // 添加缩放指示器 - 移动到底部中间
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 120),
              child: Text(
                '${_currentZoomLevel.toStringAsFixed(1)}x',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),

          // 添加相册按钮 - 右下角
          Positioned(
            bottom: 30,
            right: 30,
            child: FloatingActionButton(
              onPressed: _pickImageFromGallery,
              backgroundColor: Colors.white.withOpacity(0.7),
              child: const Icon(Icons.photo_library, color: Colors.black87),
            ),
          ),
        ],
      ),
    ));
  }

  // 添加基础缩放级别变量，用于缩放手势
  double _baseZoomLevel = 1.0;
}
