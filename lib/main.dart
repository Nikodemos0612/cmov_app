import 'package:facedetection_test_app/theme/style.dart';
import 'package:flutter/cupertino.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  final Brightness _brightness = WidgetsBinding.instance.window.platformBrightness;

  
  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      theme: _brightness == Brightness.dark ? darkCupAppTheme() : cupAppTheme(),

      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
            return (i == 0) ? const StaticImagePoseDetectorScreen() : const VideoPoseDetectorScreen();
          },
        );
      },
    );
  }
}