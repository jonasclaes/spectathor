import 'dart:io';

import 'package:applications_info/applications_info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    return ChangeNotifierProvider(
        create: (_) => AuthModel(),
        child: MaterialApp(
            title: 'Spectathor',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
            ),
            home: Consumer<AuthModel>(
              builder: (_, auth, __) => auth.isSignedIn
                  ? const HomePage(title: 'Spectathor')
                  : const LoginPage(),
            )));
  }
}

class AuthModel extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  bool get isSignedIn => supabase.auth.currentUser != null;

  Future<void> signIn({required String email, required String password}) async {
    await supabase.auth.signInWithPassword(email: email, password: password);
    notifyListeners();
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
    notifyListeners();
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                onPressed: () async {
                  final model = context.read<AuthModel>();
                  await model.signIn(
                      email: 'jonas@jonasclaes.be', password: 'admin123');
                },
                child: const Text("Login now"))
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;
  final _applicationsInfo = ApplicationsInfo();

  Future<void> _postSystemSpecs() async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo deviceInfo = await deviceInfoPlugin.androidInfo;

      List<Map<String, dynamic>> apps = [];
      var packageNames = await _applicationsInfo.getInstalledPackages();

      packageNames?.forEach((package) {
        apps.add({'packageName': package.packageName, 'name': package.name});
      });

      await supabase.from("androidDevices").insert({
        'version': deviceInfo.version.toMap(),
        'board': deviceInfo.board,
        'bootloader': deviceInfo.bootloader,
        'brand': deviceInfo.brand,
        'device': deviceInfo.device,
        'display': deviceInfo.display,
        'fingerprint': deviceInfo.fingerprint,
        'hardware': deviceInfo.hardware,
        'host': deviceInfo.host,
        'identifier': deviceInfo.id,
        'manufacturer': deviceInfo.manufacturer,
        'model': deviceInfo.model,
        'product': deviceInfo.product,
        'supported32BitAbis': deviceInfo.supported32BitAbis,
        'supported64BitAbis': deviceInfo.supported64BitAbis,
        'supportedAbis': deviceInfo.supportedAbis,
        'tags': deviceInfo.tags,
        'type': deviceInfo.type,
        'isPhysicalDevice': deviceInfo.isPhysicalDevice,
        'systemFeatures': deviceInfo.systemFeatures,
        'displayMetrics': deviceInfo.displayMetrics.toMap(),
        'serialNumber': deviceInfo.serialNumber,
        'apps': apps
      });
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
            Text("Hi, ${supabase.auth.currentUser?.email}!"),
            ElevatedButton(
                onPressed: _postSystemSpecs,
                child: const Text("Send data now")),
            ElevatedButton(
                onPressed: () async {
                  final model = context.read<AuthModel>();
                  await model.signOut();
                },
                child: const Text("Log out"))
          ],
        ),
      ),
    );
  }
}
