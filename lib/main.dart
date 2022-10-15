import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'routes.dart' as route;

bool isIOS = false;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(

      // TODO: theme que troca se o celular esta no modo escuro ou claro
      // Tentei fazer usando o arquivo "style", mas não consegui de geito algum (mesmo tentando chamar só 1)
      theme: CupertinoThemeData(
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
      ),

      debugShowCheckedModeBanner: false,

      onGenerateRoute: route.controller,
      initialRoute: route.tabControl,
    );
  }
}