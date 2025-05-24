import 'package:base_de_datos_universal/login/login_design.dart';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LoginDesign(),
  ));

  doWhenWindowReady(() {
    const initialSize = Size(850, 720);
    appWindow.minSize = initialSize;
    appWindow.maxSize = Size(1980, 1080);
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}
