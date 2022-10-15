import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:facedetection_test_app/routes.dart';

class TabControl extends StatefulWidget {
  const TabControl({Key? key}) : super(key: key);

  @override
  State<TabControl> createState() => _TabControlState();
}

class _TabControlState extends State<TabControl> {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.satellite_outlined)),

          BottomNavigationBarItem(icon: Icon(Icons.add_a_photo_outlined)),
        ],
      ),

      tabBuilder: (BuildContext context, i) {
        return CupertinoTabView(
          builder: (context){
            return (i == 0) ? cupPage('imageDetection') : cupPage('videoDetection');
          },
        );
      },
    );;
  }
}

