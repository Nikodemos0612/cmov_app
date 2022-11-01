import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:shimmer/shimmer.dart';

import 'dart:io';
import 'dart:ui' as ui;

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

  void tirarFotoEProcessar() async{
    try{
      if (controller != null){
        if (controller!.value.isInitialized) {

          controller!.setFlashMode(FlashMode.off);

          imageFile = await controller!.takePicture();
          setState(() {});

          print(" ============================ FOTO TIRADA =====================================");

          if (imageFile != null) {
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

  void getPosesFromImage(XFile image) async{
    final inputImage = InputImage.fromFilePath(image.path);

    final options = PoseDetectorOptions();
    final poseDetector = PoseDetector(options: options);

    final List<Pose> poses = await poseDetector.processImage(inputImage);

    await poseDetector.close();

    this.poses = poses;

    if (poses.isEmpty){
      print("Não foi encontrado nenhuma pose");
    }

    setState(() {});

    print("================================== IMAGEM PROCESSADA =========================================");
  }

  @override
  void initState() {
    super.initState();
    loadCamera();

  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CupertinoScrollbar(

        child: Center(
          child: Column(
            children: [

              Container(
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
                      foregroundPainter: PosePainter(poses),
                      child: CameraPreview(controller!),
                    )
              ),

              TextButton(
                onPressed: tirarFotoEProcessar,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.orange
                ),

                child: const Text("FUNCIONAAAAA"),
              )
            ],
          ),
        ),
      ),

    );
  }
}

// Desenha as poses na camera
class PosePainter extends CustomPainter{

  final List<Pose>? poses;

  PosePainter(this.poses);

  @override
  void paint (Canvas canvas, Size size){

    if (poses != null && poses!.isNotEmpty){
      for (Pose pose in poses!) {
        pose.landmarks.forEach((_, landmark) {
          // Pega o nome do local do corpo
          //final type = landmark.type;

          // Pega a localização dele na imagem
          final x = landmark.x;
          final y = landmark.y;
          //final z = landmark.z; // ATENÇÃO: z é uma variavel não tão precisa quanto x e y, tomar cuidado quando utiliza-la

          final myPaint = Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 10
            ..color = Colors.orange;

          canvas.drawCircle(Offset(x, y), 25, myPaint);
        });
      }
    }
  }

  @override
  bool shouldRepaint (PosePainter oldDelegate) {
    return poses != oldDelegate.poses;
  }
}