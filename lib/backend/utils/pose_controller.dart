import 'dart:async';
import 'dart:html';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseController{
  FirebaseDatabase database = FirebaseDatabase.instance;


  static void setPose(String poseLocation, double? x, double? y, double? z, double? likelihood) async {

    DatabaseReference ref = FirebaseDatabase.instance.ref(poseLocation);

    await ref.set({
      "x": x,
      "y": y,
      "z": z,
      "likelihood": likelihood
    });
  }

  static Future<DataSnapshot> getPose(String poseLocation) async{

    DatabaseReference ref = FirebaseDatabase.instance.ref(poseLocation);

    return await ref.get();
  }

  static void setAllPoses(List<Pose> poses) async{

    for (Pose pose in poses) {

      final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
      final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
      final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];

      final rightElbow = pose.landmarks[PoseLandmarkType.rightElbow];
      final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
      final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];
      
      setPose("Poses/LeftElbow", leftElbow?.x, leftElbow?.y, leftElbow?.z, leftElbow?.likelihood);
      setPose("Poses/LeftShoulder", leftShoulder?.x, leftShoulder?.y, leftShoulder?.z, leftShoulder?.likelihood);
      setPose("Poses/LeftWrist", leftWrist?.x, leftWrist?.y, leftWrist?.z, leftWrist?.likelihood);

      setPose("Poses/RightElbow", rightElbow?.x, rightElbow?.y, rightElbow?.z, rightElbow?.likelihood);
      setPose("Poses/RightShoulder", rightShoulder?.x, rightShoulder?.y, rightShoulder?.z, rightShoulder?.likelihood);
      setPose("Poses/RightWrist", rightWrist?.x, rightWrist?.y, rightWrist?.z, rightWrist?.likelihood);
    }
  }
}