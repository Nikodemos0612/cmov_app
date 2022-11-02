import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart'; // MLKit responsavel por detectar poses
import 'package:path_provider/path_provider.dart';
import 'package:shimmer/shimmer.dart'; // Animação de "carregado" ou "brilhando"

import 'dart:io';
import 'dart:ui' as UI; // Imagem

import 'dart:ffi'; // Responsavel pela conversão da imagem com o código em C++
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:image/image.dart' as imglib;



typedef convert_func = Pointer<Uint32> Function(
    Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>,
    Int32, Int32, Int32, Int32
    );
typedef Convert = Pointer<Uint32> Function(
    Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>,
    int, int, int, int
    );



class VideoPoseDetectionScreen extends StatefulWidget {
  const VideoPoseDetectionScreen({Key? key}) : super(key: key);

  @override
  State<VideoPoseDetectionScreen> createState() => _VideoPoseDetectionScreenState();
}

class _VideoPoseDetectionScreenState extends State<VideoPoseDetectionScreen> {

  List<CameraDescription>? _cameras; // Lista de cameras disponíveis
  CameraController? _cameraController; // Controlador
  XFile? _imageFile; // A imagem tirada
  List<Pose>? _poses; // Lista das poses na foto
  imglib.Image? _image; // A foto em si

  CameraImage? _savedImage;

  bool _poseScanning = false;
  bool _pausar = true;

  final _cameraWidgetKey = GlobalKey();
  UI.Size? _cameraWidgetSize;

  void _getCameraSize() {
    setState(() {
      _cameraWidgetSize = _cameraWidgetKey.currentContext!.size;
    });
  }

  final DynamicLibrary convertImageLib = Platform.isAndroid
      ? DynamicLibrary.open("libconvertImage.so")
      : DynamicLibrary.process();
  Convert? conv;


  void _loadCamera() async{
    // Pega uma lista de cameras disponíveis
    _cameras = await availableCameras();

    if (_cameras != null) {
      // camera[0] = primeira camera
      _cameraController = CameraController(_cameras![0], ResolutionPreset.max);

      // Inicia o controlador
      _cameraController!.initialize().then((_) async{

        // Inicia imageStream
        await _cameraController!.startImageStream((CameraImage image) => _processCameraImage(image));

        setState(() {});
      });
    }
    else{
      print("Não foi encontrado nenhuma camera");
    }

    if (_cameraController != null) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCamera();

    // Carrega a função em c++ de conversão de imagem.
    conv = convertImageLib
        .lookup<NativeFunction<convert_func>>('convertImage')
        .asFunction<Convert>();
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
                    child: _cameraController == null? // Carregando camera
                    Shimmer.fromColors(
                        baseColor: Colors.black,
                        highlightColor: Colors.white,
                        child: const SizedBox(width: double.infinity, height: 300,)
                    )
                        :
                    !_cameraController!.value.isInitialized? // Achou camera mas ainda está carregando
                    const Align(alignment: Alignment.center, child: CircularProgressIndicator(color: Colors.orange,),)
                        :
                    CustomPaint(
                      foregroundPainter: PosePainter(_poses, _image, _cameraWidgetSize, _pausar),
                      child: CameraPreview(_cameraController!, key: _cameraWidgetKey,),
                    ),
                  ),

                  if (_cameraController != null && _cameraController!.value.isInitialized)
                    _pausar?
                      MaterialButton(
                        onPressed: () {
                          if (!_poseScanning){ // Evita chamar novamente se ja estiver rodando
                            // Isso pode acontecer caso o usuário aperte varias vezes o botão
                            _pausar = false;
                            setState(() {});

                            _getCameraSize();
                            _takePictureAndTakePoses();
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

  void _processCameraImage(CameraImage image) async{
    setState(() {
      _savedImage = image;
    });
  }

  void _takePictureAndTakePoses() async{
    if (_pausar){
      setState(() {_poseScanning = false;});
      return;
    }

    _poseScanning = true;
    setState(() {});

    try{
      if (_cameraController != null && _cameraController!.value.isInitialized && _savedImage != null && conv != null){

        // Allocate memory for the 3 planes of the image
        Pointer<Uint8> p = calloc.allocate(
            _savedImage!.planes[0].bytes.length
        );
        Pointer<Uint8> p1 = calloc.allocate(
            _savedImage!.planes[1].bytes.length
        );
        Pointer<Uint8> p2 = calloc.allocate(
            _savedImage!.planes[2].bytes.length
        );

        // Assign the planes data to the pointers of the image
        Uint8List pointerList = p.asTypedList(
            _savedImage!.planes[0].bytes.length
        );
        Uint8List pointerList1 = p1.asTypedList(
            _savedImage!.planes[1].bytes.length
        );
        Uint8List pointerList2 = p2.asTypedList(
            _savedImage!.planes[2].bytes.length
        );
        pointerList.setRange(0, _savedImage!.planes[0].bytes.length, _savedImage!.planes[0].bytes);
        pointerList1.setRange(0, _savedImage!.planes[1].bytes.length, _savedImage!.planes[1].bytes);
        pointerList2.setRange(0, _savedImage!.planes[2].bytes.length, _savedImage!.planes[2].bytes);

        Pointer<Uint32> imgP = conv!(p, p1, p2, _savedImage!.planes[1].bytesPerRow, _savedImage!.planes[1].bytesPerPixel!, _savedImage!.width, _savedImage!.height);
        // Get the pointer of the data returned from the function to a List
        List<int> imgData = imgP.asTypedList(_savedImage!.width * _savedImage!.height);
        // Generate image from the converted data
        imglib.Image img = imglib.Image.fromBytes(_savedImage!.height, _savedImage!.width, imgData);

        // Free the memory space allocated
        // from the planes and the converted data
        calloc.free(p);
        calloc.free(p1);
        calloc.free(p2);
        calloc.free(imgP);

        final directory = await getTemporaryDirectory();
        final filepath = "abc.png";
        File imgFile = File(filepath);
        imgFile.writeAsBytes(img.getBytes());
        _image = img;
        setState(() {});

        _getPosesFromImage(imgFile.path);
      }
    }
    catch (e)
    {
      setState(() {_imageFile = null; _image = null;});

      print(e);
    }
  }

  void _getPosesFromImage(String path) async{
    final inputImage = InputImage.fromFilePath(path);

    final options = PoseDetectorOptions();
    final poseDetector = PoseDetector(options: options);

    final List<Pose> poses = await poseDetector.processImage(inputImage);

    await poseDetector.close();

    _poses = poses;
    setState(() {});

    if (poses.isEmpty){
      print("Não foi encontrado nenhuma pose");
    }

    _takePictureAndTakePoses();
  }
}

// Desenha as poses na camera
class PosePainter extends CustomPainter{

  final List<Pose>? poses;
  final imglib.Image? image;
  UI.Size ?cameraSize;
  bool pause;

  //final CameraController controller;

  PosePainter(this.poses, this.image, this.cameraSize, this.pause);

  @override
  void paint (Canvas canvas, UI.Size size){

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