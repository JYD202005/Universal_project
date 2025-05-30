import 'package:base_de_datos_universal/login/login_design.dart';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://cayjxxtaixhnxlllaccp.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNheWp4eHRhaXhobnhsbGxhY2NwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc4NTcxNzksImV4cCI6MjA2MzQzMzE3OX0.a9cL4cNkpaBhggbx3pmBkNz8RE1uxImCEU99nZ_6NXk',
  );

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LoginDesign(),
  ));

  doWhenWindowReady(() {
    const initialSize = Size(850, 730);
    appWindow.minSize = initialSize;
    appWindow.maxSize = Size(1980, 1080);
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginDesign(),
    );
  }
}
