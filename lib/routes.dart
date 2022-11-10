import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:pose_detection_app/views/screens/image_pose_detection.dart';
import 'package:pose_detection_app/views/screens/video_pose_detection.dart';
import 'package:pose_detection_app/views/screens/tab_control.dart';

// Route Names
const String tabControl = 'tabControl';
const String videoPoseDetectionTab = 'videoDetection';
const String imagePoseDetectionTab = 'imageDetection';

Route<dynamic> controller(RouteSettings settings){

  switch(settings.name){
    case tabControl:
      return CupertinoPageRoute(builder: (context) => const TabControl());

    default:
      throw('Não existe uma rota com esse nome');
  }
}

cupPage(String routeName){

  switch(routeName){
    case imagePoseDetectionTab:
      return const StaticImagePoseDetectorScreen();

    case videoPoseDetectionTab:
      return const VideoPoseDetectionScreen();

    default:
      throw('Não existe uma rota com esse nome');
  }
}