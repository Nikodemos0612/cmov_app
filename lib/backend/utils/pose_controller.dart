import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseController{

  static FirebaseDatabase database = FirebaseDatabase.instance;


  static Future<void> updatePose(String poseLocation, double? x, double? y, double? z, double? likelihood) async {

    DatabaseReference ref = database.ref(poseLocation);

    await ref.update({
      "x": x,
      "y": y,
      "z": z,
      "likelihood": likelihood
    })
    .then((value) => print("Pose $poseLocation foi passada para o database"))
    .catchError((error) => print("ERRO: $error"));

  }

  static Future<DataSnapshot> getPose(String poseLocation) async{

    DatabaseReference ref = database.ref(poseLocation);

    DataSnapshot data = await ref.get();

    return data;
  }

  static Future<void> setAllPoses(List<Pose> poses) async{

    if (poses.isNotEmpty){
      for (Pose pose in poses) {
        final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
        final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
        final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];

        final rightElbow = pose.landmarks[PoseLandmarkType.rightElbow];
        final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
        final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];


        DatabaseReference ref = database.ref("Poses");

        await ref.update({
          "leftElbow": {
            "x": leftElbow?.x,
            "y": leftElbow?.y,
            "z": leftElbow?.z,
            "likelihood": leftElbow?.likelihood
          },
          "leftShoulder": {
            "x": leftShoulder?.x,
            "y": leftShoulder?.y,
            "z": leftShoulder?.z,
            "likelihood": leftShoulder?.likelihood
          },
          "leftWrist": {
            "x": leftWrist?.x,
            "y": leftWrist?.y,
            "z": leftWrist?.z,
            "likelihood": leftWrist?.likelihood
          },

          "rightElbow": {
            "x": rightElbow?.x,
            "y": rightElbow?.y,
            "z": rightElbow?.z,
            "likelihood": rightElbow?.likelihood
          },
          "rightShoulder": {
            "x": rightShoulder?.x,
            "y": rightShoulder?.y,
            "z": rightShoulder?.z,
            "likelihood": rightShoulder?.likelihood
          },
          "rightWrist": {
            "x": rightWrist?.x,
            "y": rightWrist?.y,
            "z": rightWrist?.z,
            "likelihood": rightWrist?.likelihood
          },
        });

        /*await updatePose("Poses/LeftElbow", leftElbow?.x, leftElbow?.y, leftElbow?.z, leftElbow?.likelihood);
        await updatePose("Poses/LeftShoulder", leftShoulder?.x, leftShoulder?.y, leftShoulder?.z, leftShoulder?.likelihood);
        await updatePose("Poses/LeftWrist", leftWrist?.x, leftWrist?.y, leftWrist?.z, leftWrist?.likelihood);

        await updatePose("Poses/RightElbow", rightElbow?.x, rightElbow?.y, rightElbow?.z, rightElbow?.likelihood);
        await updatePose("Poses/RightShoulder", rightShoulder?.x, rightShoulder?.y, rightShoulder?.z, rightShoulder?.likelihood);
        await updatePose("Poses/RightWrist", rightWrist?.x, rightWrist?.y, rightWrist?.z, rightWrist?.likelihood);
      */
      }
    }
  }

  static void resetAllPoses() async{

  }
}