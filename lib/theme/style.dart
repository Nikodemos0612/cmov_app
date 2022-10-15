import 'package:flutter/cupertino.dart';
// Cupertino themes

// TENTEI E NN FUNCIONA, VOU IGNORAR

  CupertinoThemeData cupAppTheme() {
    return CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: CupertinoColors.activeOrange,
        primaryContrastingColor: CupertinoColors.white,

        textTheme: CupertinoTextThemeData(
            textStyle: TextStyle(
                fontFamily: 'Arial'
            ),

            navLargeTitleTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 70.0,
                color: CupertinoColors.systemOrange
            )
        )
    );
  }

  CupertinoThemeData darkCupAppTheme() {
    return CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: CupertinoColors.activeOrange,
        primaryContrastingColor: CupertinoColors.white,

        textTheme: CupertinoTextThemeData(
            textStyle: TextStyle(
                fontFamily: 'Arial',
                color: CupertinoColors.white
            ),

            navLargeTitleTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 70.0,
                color: CupertinoColors.systemOrange
            )
        )
    );
  }

// Material Themes
/*
ThemeData matAppTheme() {
  return const ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.orange,

    textTheme: TextTheme(
      textStyle: TextStyle(
        fontFamily: 'Arial'
      ),

      navLargeTitleTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 70.0,
        color: CupertinoColors.systemOrange
      )
    )
  );
}

CupertinoThemeData darkCupAppTheme() {
  return const CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: CupertinoColors.activeOrange,
    primaryContrastingColor: CupertinoColors.white,

    textTheme: CupertinoTextThemeData(
      textStyle: TextStyle(
        fontFamily: 'Arial',
        color: CupertinoColors.white
      ),
      
      navLargeTitleTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 70.0,
        color: CupertinoColors.systemOrange
      )
    )
  );
}*/