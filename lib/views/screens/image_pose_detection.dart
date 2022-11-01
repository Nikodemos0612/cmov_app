import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui' as UI;

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:shimmer/shimmer.dart';

class StaticImagePoseDetectorScreen extends StatefulWidget {
  const StaticImagePoseDetectorScreen({Key? key}) : super(key: key);

  @override
  State<StaticImagePoseDetectorScreen> createState() => _StaticImagePoseDetectorScreenState();
}

class _StaticImagePoseDetectorScreenState extends State<StaticImagePoseDetectorScreen> {
  bool poseScanning = false;
  XFile? imageFile;
  UI.Image? image;
  List<Pose>? posesFromImage;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
          child: Padding(
            padding: EdgeInsets.only(top: 30),
            child: CupertinoScrollbar(
              child: Center(
                  child: Column(
                      children: [

                        if (poseScanning)
                          AspectRatio(
                            aspectRatio: 9/15,
                            child: Shimmer.fromColors(
                                baseColor: Colors.grey,
                                highlightColor: Colors.black12,
                                period: const Duration(seconds: 1),
                                child: Padding(
                                    padding: EdgeInsets.fromLTRB(15, 15, 15, 5),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white60,
                                          borderRadius: BorderRadius.circular(10)
                                      ),
                                    )
                                )
                            ),
                          ),

                        if (!poseScanning && imageFile == null)
                          AspectRatio(
                            aspectRatio: 9/15,
                            child: Stack(
                              children: <Widget>[

                                Shimmer.fromColors(
                                    baseColor: Colors.grey,
                                    highlightColor: Colors.black12,
                                    period: const Duration(seconds: 5),
                                    child: Padding(
                                        padding: EdgeInsets.fromLTRB(15, 15, 15, 5),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white60,
                                              borderRadius: BorderRadius.circular(10)
                                          ),
                                        )
                                    )
                                ),

                                Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  child: const Center(child: (Text("Adicione uma imagem")),),
                                ),
                              ],
                            ),
                          ),

                        if (image != null && posesFromImage != null && !poseScanning)
                          FittedBox(
                              child: SizedBox(
                                width: image!.width.toDouble(),
                                height: image!.height.toDouble(),
                                child: PosePaint(),
                              )
                          ),

                        SizedBox(
                          width: double.infinity,
                          child: Center(
                            child: Row(
                              children: [
                                CupertinoButton(
                                  onPressed: () => getImageFromGallery(),
                                  child: const Icon(CupertinoIcons.add),
                                ),

                                CupertinoButton(
                                  onPressed: () => getImageFromCamera(),
                                  child: const Icon(Icons.add_a_photo),
                                )
                              ],
                            ),
                          )
                        )

                      ],
                    ),
                  )
              )
          )
    );
  }

  void getImageFromGallery() async{
    try{
      final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedImage != null){
        poseScanning = true;
        imageFile = pickedImage;
        setState(() {});

        image = await _loadImage(File(pickedImage.path));
        setState(() {});

        getPoseFromImage(pickedImage);
      }
    }
    catch (e){
      poseScanning = false;
      imageFile = null;
      image = null;

      setState(() {});
    }
  }

  void getImageFromCamera() async{
    try{
      final pickedImage = await ImagePicker().pickImage(source: ImageSource.camera);

      if (pickedImage != null){
        poseScanning = true;
        imageFile = pickedImage;
        setState(() {});

        image = await _loadImage(File(pickedImage.path));
        setState(() {});

        getPoseFromImage(pickedImage);
      }
    }
    catch (e){
      poseScanning = false;
      imageFile = null;
      image = null;

      setState(() {});
    }

  }

  Future<UI.Image> _loadImage(File file) async {
    final data = await file.readAsBytes();
    return await decodeImageFromList(data);
  }

  void getPoseFromImage(XFile image) async{
    final inputImage = InputImage.fromFilePath(image.path);

    final options = PoseDetectorOptions();
    final poseDetector = PoseDetector(options: options);

    final List<Pose> poses = await poseDetector.processImage(inputImage);

    await poseDetector.close();

    posesFromImage = poses;

    poseScanning = false;
    setState(() {});
  }

  CustomPaint PosePaint() {
    if (image != null && posesFromImage != null){
      return CustomPaint(painter: PosePainter(image!, posesFromImage!),);
    } //! em fim de variavel indica que ela não vai ser nulla
    else
      return CustomPaint();
  }
}

class PosePainter extends CustomPainter{

  final UI.Image image;
  final List<Pose> poses;

  PosePainter(this.image, this.poses);

  bool isImageDiferent = false;

  @override
  void paint (Canvas canvas, Size size){

    // Desenha a imagem
    canvas.drawImage(image, Offset.zero, Paint());

    if (poses.isNotEmpty){
      var pointPainter = Paint()
        ..color = Colors.orange
        ..strokeCap = StrokeCap.round //rounded points
        ..strokeWidth = 10;

      for (Pose pose in poses) {
        pose.landmarks.forEach((_, landmark) {
          // Pega o nome do local do corpo
          final type = landmark.type;

          // Pega a localização dele na imagem
          final x = landmark.x;
          final y = landmark.y;
          final z = landmark.z; // ATENÇÃO: z é uma variavel não tão precisa quanto x e y, tomar cuidado quando utiliza-la

          canvas.drawCircle(Offset(x, y), 25, pointPainter);
        });
      }
    }
    // Desenha os pontos do esqueleto
  }

  @override
  bool shouldRepaint (PosePainter oldDelegate) {
    if (image != oldDelegate.image)
      isImageDiferent = true;

    if (isImageDiferent && poses != oldDelegate.poses){
      isImageDiferent = false;
      return true;
    }

    return false;
  }

}
