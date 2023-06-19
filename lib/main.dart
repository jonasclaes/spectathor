import 'dart:io';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:device_info_plus/device_info_plus.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://ugjiiuzfdlfbybcfpvdh.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVnamlpdXpmZGxmYnliY2ZwdmRoIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODcxNzM4MjUsImV4cCI6MjAwMjc0OTgyNX0.QZ-pgcA0RPgTOLVSxm_w1a6T-onlhPe6diG8UjWm7DQ',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spectathor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Spectathor'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<void> _postSystemSpecs() async {
    final supabase = Supabase.instance.client;
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo deviceInfo = await deviceInfoPlugin.androidInfo;

      await supabase
          .from("androidDevices")
          .insert({'brand': deviceInfo.brand, 'model': deviceInfo.model});
    }

    if (Platform.isWindows) {
      WindowsDeviceInfo deviceInfo = await deviceInfoPlugin.windowsInfo;

      await supabase.from("windowsDevices").insert({
        'computerName': deviceInfo.computerName,
        'numberOfCores': deviceInfo.numberOfCores,
        'systemMemoryInMegabytes': deviceInfo.systemMemoryInMegabytes,
        'userName': deviceInfo.userName,
        'majorVersion': deviceInfo.majorVersion,
        'minorVersion': deviceInfo.minorVersion,
        'buildNumber': deviceInfo.buildNumber,
        'platformId': deviceInfo.platformId,
        'csdVersion': deviceInfo.csdVersion,
        'servicePackMajor': deviceInfo.servicePackMajor,
        'servicePackMinor': deviceInfo.servicePackMinor,
        'suitMask': deviceInfo.suitMask,
        'productType': deviceInfo.productType,
        'buildLab': deviceInfo.buildLab,
        'buildLabEx': deviceInfo.buildLabEx,
        'digitalProductId': deviceInfo.digitalProductId,
        'displayVersion': deviceInfo.displayVersion,
        'editionId': deviceInfo.editionId,
        'installDate': deviceInfo.installDate.toIso8601String(),
        'productId': deviceInfo.productId,
        'productName': deviceInfo.productName,
        'registeredOwner': deviceInfo.registeredOwner,
        'releaseId': deviceInfo.releaseId,
        'deviceId': deviceInfo.deviceId
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                onPressed: _postSystemSpecs, child: const Text("Send data now"))
          ],
        ),
      ),
    );
  }
}
