import 'dart:io';
import 'package:cmov_app/firebase_options.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'routes.dart' as route;

bool isIOS = false;

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  final Future<FirebaseApp> _fbApp = Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  @override
  Widget build(BuildContext context) {
    // Firebase instance

    return CupertinoApp(

      // TODO: theme que troca se o celular esta no modo escuro ou claro
      // Tentei fazer usando o arquivo "style", mas não consegui de geito algum (mesmo tentando chamar só 1)
      theme: const CupertinoThemeData(
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

      //onGenerateRoute: route.controller,
      //initialRoute: route.tabControl,

      home: FutureBuilder(
        future: _fbApp,
        builder: (context, snapshot){
          if (snapshot.hasError){
            print(snapshot.error);
            return Center(child: Text("Ocorreu um erro, ${snapshot.error}"));
          }
          else if (snapshot.hasData){
            return route.cupPage('tabControl');
          }
          else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      )
    );
  }
}