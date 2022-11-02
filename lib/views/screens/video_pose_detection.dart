import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:shimmer/shimmer.dart';

import 'dart:io';
import 'dart:ui' as UI;

import 'package:facedetection_test_app/routes.dart';

class VideoPoseDetectionScreen extends StatefulWidget {
  const VideoPoseDetectionScreen({Key? key}) : super(key: key);

  @override
  State<VideoPoseDetectionScreen> createState() => _VideoPoseDetectionScreenState();
}

class _VideoPoseDetectionScreenState extends State<VideoPoseDetectionScreen> {

  List<CameraDescription>? cameras; // Lista de cameras disponíveis
  CameraController? controller;
  XFile? imageFile; // A imagem tirada
  List<Pose>? poses;
  UI.Image? image;

  bool poseScanning = false;
  bool pausar = true;

  final _cameraWidgetKey = GlobalKey();
  Size? _cameraWidgetSize;

  void getSize() {
    setState(() {
      _cameraWidgetSize = _cameraWidgetKey.currentContext!.size;
    });
  }

  void loadCamera() async{
    cameras = await availableCameras();

    if (cameras != null) {
      // camera[0] = primeira camera
      controller = CameraController(cameras![0], ResolutionPreset.max);

      controller!.initialize().then((value) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    }
    else{
      print("Não foi encontrado nenhuma camera");
    }

    if (controller != null) {
      setState(() {});
    }
  }

  void takePictureAndTakePoses() async{
    if (pausar){
      poseScanning = false;
      setState(() {});
      return;
    }

    poseScanning = true;
    setState(() {});

    try{
      if (controller != null){
        if (controller!.value.isInitialized) {

          controller!.setFlashMode(FlashMode.off);

          imageFile = await controller!.takePicture();
          setState(() {});

          if (imageFile != null) {
            image = await _loadImage(File(imageFile!.path));
            setState(() {});
            getPosesFromImage(imageFile!);
          }
          else{
            print("Imagem deu nullo por algum motivo");
          }
        }
      }
    }
    catch (e)
    {
      imageFile = null;
      setState(() {});

      print(e);
    }
  }

  Future<UI.Image> _loadImage(File file) async {
    final data = await file.readAsBytes();
    return await decodeImageFromList(data);
  }

  void getPosesFromImage(XFile image) async{
    final inputImage = InputImage.fromFilePath(image.path);

    final options = PoseDetectorOptions();
    final poseDetector = PoseDetector(options: options);

    final List<Pose> poses = await poseDetector.processImage(inputImage);

    await poseDetector.close();

    this.poses = poses;
    setState(() {});

    if (poses.isEmpty){
      print("Não foi encontrado nenhuma pose");
    }

    takePictureAndTakePoses();
  }

  @override
  void initState() {
    super.initState();
    loadCamera();
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
                    child: controller == null? // Carregando camera
                    Shimmer.fromColors(
                        baseColor: Colors.black,
                        highlightColor: Colors.white,
                        child: const SizedBox(width: double.infinity, height: 300,)
                    )
                        :
                    !controller!.value.isInitialized? // Achou camera mas ainda está carregando
                    const Align(alignment: Alignment.center, child: CircularProgressIndicator(color: Colors.orange,),)
                        :
                    CustomPaint(
                      foregroundPainter: PosePainter(poses, image, _cameraWidgetSize, pausar),
                      child: CameraPreview(controller!, key: _cameraWidgetKey,),
                    ),
                  ),

                  if (controller != null && controller!.value.isInitialized)
                    pausar?
                      MaterialButton(
                        onPressed: () {
                          if (!poseScanning){ // Evita chamar novamente se ja estiver rodando
                            // Isso pode acontecer caso o usuário aperte varias vezes o botão
                            pausar = false;
                            setState(() {});

                            getSize();
                            takePictureAndTakePoses();
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
                          pausar = true;
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

  final List<Pose>? poses;
  final UI.Image? image;
  Size ?cameraSize;
  bool pause;

  //final CameraController controller;

  PosePainter(this.poses, this.image, this.cameraSize, this.pause);

  @override
  void paint (Canvas canvas, Size size){

    if (poses != null && poses!.isNotEmpty && image != null && !pause && cameraSize != null){
      var pointPainter = Paint()
        ..color = Colors.orange
        ..strokeCap = StrokeCap.round //rounded points
        ..strokeWidth = 10;

      int imageWidth = image!.width;
      int imageHeight = image!.height;

      for (Pose pose in poses!) {
        pose.landmarks.forEach((_, landmark) {
          // Pega o nome do local do corpo
          //final type = landmark.type;

          // Pega a localização dele na imagem
          final x = landmark.x / imageWidth;
          final y = landmark.y / imageHeight;
          //final z = landmark.z; // ATENÇÃO: z é uma variavel não tão precisa quanto x e y, tomar cuidado quando utiliza-la

          canvas.drawCircle(Offset(x * cameraSize!.width, y * cameraSize!.height), 25, pointPainter);
        });
      }
    }
  }

  @override
  bool shouldRepaint (PosePainter oldDelegate) {

    if (pause != oldDelegate.pause) {
      return true;
    }

    if (poses == null) {
      return false;
    }

    if (poses!.isEmpty) {
      return false;
    }

    return poses != oldDelegate.poses;
  }
}