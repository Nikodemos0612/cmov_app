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
      print("Celular sem camera amigo?");
    }
  }

  void tirarFotoEProcessar() async{
    try{
      if (controller != null){
        if (controller!.value.isInitialized) {

        imageFile = await controller!.takePicture();
        setState(() {});

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
    setState(() {});

    //tirarFotoEProcessar();
  }

  @override
  void initState() {
    super.initState();
    loadCamera();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,

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
                  !controller!.value.isInitialized?
                    const Align(alignment: Alignment.center, child: CircularProgressIndicator(color: Colors.orange,),) 
                    :
                  poses == null? // Camera carregada
                    CameraPreview(controller!)
                    :
                    CustomPaint(
                      foregroundPainter: PosePainter(poses!),
                      child: CameraPreview(controller!),
                    )
              ),

              TextButton(onPressed: tirarFotoEProcessar, child: Text("FUNCIONAAAAAA"))
            ],
          ),
        ),
      ),

    );
  }
}

class PosePainter extends CustomPainter{

  final List<Pose> poses;

  PosePainter(this.poses);

  bool isPosesDiferent = false;

  @override
  void paint (Canvas canvas, Size size){

    for (Pose pose in poses) {
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

  @override
  bool shouldRepaint (PosePainter oldDelegate) {
    return poses != oldDelegate.poses;
  }
}