import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:shimmer/shimmer.dart';

class VideoPoseDetectionScreen extends StatefulWidget {
  const VideoPoseDetectionScreen({Key? key}) : super(key: key);

  @override
  State<VideoPoseDetectionScreen> createState() => _VideoPoseDetectionScreenState();
}

class _VideoPoseDetectionScreenState extends State<VideoPoseDetectionScreen> with WidgetsBindingObserver{

  List<CameraDescription>? _cameras; // Lista de cameras disponíveis
  CameraController? _controller;
  List<Pose>? _poses;

  int _poseScanningCount = 0;
  bool _pausar = true;

  final _cameraWidgetKey = GlobalKey();
  Size? _cameraWidgetSize, _pictureSize;

  void _getSize() {
    setState(() {
      _cameraWidgetSize = _cameraWidgetKey.currentContext!.size;
    });
  }

  void _loadCamera() async{
    _cameras = await availableCameras();

    if (_cameras != null) {
      // camera[0] = primeira camera
      _controller = CameraController(_cameras![0], ResolutionPreset.max, enableAudio: false);

      _controller!.initialize().then((value) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    }
    else{
      print("Não foi encontrado nenhuma camera");
    }

    if (_controller != null) {
      setState(() {});
    }
  }

  @override
  void dispose(){
    _pausar = true;
    setState(() {});

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _getPosesFromImage(CameraImage image) async {
    try {
      // Evita o programa rodar mais de uma vez
      if (_poseScanningCount >= 4|| _cameras == null)
        return;

      _poseScanningCount ++;
      setState(() {});

      // "Tirar Foto" ==========================================================

      final WriteBuffer allBytes = WriteBuffer();
      for (Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      _pictureSize = Size(image.width.toDouble(), image.height.toDouble());
      setState(() {});

      final InputImageRotation imageRotation =
          InputImageRotationValue.fromRawValue(
              _cameras![0].sensorOrientation) ??
              InputImageRotation.rotation90deg;

      final InputImageFormat inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.yuv420;

      final planeData = image.planes.map(
            (Plane plane) {
          return InputImagePlaneMetadata(
            bytesPerRow: plane.bytesPerRow,
            //height: plane.height,
            //width: plane.width,
          );
        },
      ).toList();

      final inputImageData = InputImageData(
        size: _pictureSize!,
        imageRotation: imageRotation,
        inputImageFormat: inputImageFormat,
        planeData: planeData,
      );

      final inputImage =
      InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);



      // Inicio do calculo das poses ===========================================

      final options = PoseDetectorOptions();
      final poseDetector = PoseDetector(options: options);

      final List<Pose> poses = await poseDetector.processImage(inputImage);

      await poseDetector.close();

      _poses = poses;
      _poseScanningCount --;
      setState(() {});

      if (poses.isEmpty) {
        print("Não foi encontrado nenhuma pose");
      }
    }
    catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
      _pausar = true;
      setState(() {});
    } else if (state == AppLifecycleState.resumed) {
      if (_controller != null) {
        _loadCamera();
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.black,
      child: CupertinoScrollbar(
        child: SizedBox.expand(
          child: Center(
              child: Stack(
                children: <Widget>[
                  Center(
                    child: _controller == null? // Carregando camera
                    Shimmer.fromColors(
                        baseColor: Colors.black,
                        highlightColor: Colors.white,
                        child: const SizedBox(width: double.infinity, height: 300,)
                    )
                        :
                    !_controller!.value.isInitialized? // Achou camera mas ainda está carregando
                    const Align(alignment: Alignment.center, child: CircularProgressIndicator(color: Colors.orange,),)
                        :
                    CustomPaint(
                      foregroundPainter: PosePainter(_poses, _pictureSize, _cameraWidgetSize, _pausar),
                      child: Padding(child: CameraPreview(_controller!, key: _cameraWidgetKey,), padding: EdgeInsets.only(bottom: 35),),
                    ),
                  ),

                  if (_controller != null && _controller!.value.isInitialized)
                    _pausar?
                      MaterialButton(
                        onPressed: () {
                          if (_poseScanningCount <= 0 && _controller!= null){ // Evita chamar novamente se ja estiver rodando
                            // Isso pode acontecer caso o usuário aperte varias vezes o botão
                            _pausar = false;
                            setState(() {});

                            _getSize();
                            _controller!.startImageStream((image) async{
                              if (_pausar) {
                                _controller!.stopImageStream();
                                return;
                              }

                              _getPosesFromImage(image);
                            });
                          }
                        },
                        child: Container(
                          alignment: Alignment.bottomCenter,
                          child: const Padding(
                            padding: EdgeInsets.only(bottom: 100),
                            child: Icon(Icons.play_arrow, color: Colors.white, size: 40,),
                          ),
                        ),
                      )
                    :
                      MaterialButton(
                        onPressed: () {
                          _pausar = true;
                          setState(() {});
                        },
                        child: Container(
                          alignment: Alignment.bottomCenter,
                          child: const Padding(
                              padding: EdgeInsets.only(bottom: 100),
                              child: Icon(Icons.pause, color: Colors.white, size: 40,)
                          ),
                        )
                    )
                ],
              )
          ),
        ),
      ),
    );
  }
}

// Desenha as poses na camera
class PosePainter extends CustomPainter{

  final List<Pose>? _poses;
  final Size? _pictureSize;
  final Size? _cameraSize;
  final bool _pause;

  //final CameraController controller;

  PosePainter(this._poses, this._pictureSize, this._cameraSize, this._pause);

  @override
  void paint (Canvas canvas, Size size){

    if (_poses != null && _poses!.isNotEmpty && _pictureSize != null && _cameraSize != null && !_pause){
      var pointPainter = Paint()
        ..color = Colors.orange
        ..strokeCap = StrokeCap.round //rounded points
        ..strokeWidth = 10;

      for (Pose pose in _poses!) {
        pose.landmarks.forEach((_, landmark) {
          // Pega o nome do local do corpo
          //final type = landmark.type;

          // Pega a localização dele na imagem
          final x = landmark.x / _pictureSize!.height;
          final y = landmark.y / _pictureSize!.width;
          //final z = landmark.z; // ATENÇÃO: z é uma variavel não tão precisa quanto x e y, tomar cuidado quando utiliza-la

          canvas.drawCircle(Offset(x * _cameraSize!.width, y * _cameraSize!.height), 10, pointPainter);
        });
      }
    }
  }

  @override
  bool shouldRepaint (PosePainter oldDelegate) {

    if (_pause != oldDelegate._pause) {
      return true;
    }

    if (_poses == null || _poses!.isEmpty) {
      return false;
    }

    return _poses != oldDelegate._poses;
  }
}