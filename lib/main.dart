import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sizer/sizer.dart';
import 'package:we_tools/i18n/mytranslate.dart';
import 'package:we_tools/page/qrcode.dart';
import 'package:we_tools/page/scanner.dart';
import 'package:we_tools/page/setting_list.dart';
import 'package:we_tools/page/tools_list.dart';
import 'package:we_tools/services/utils.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // 必须确保初始化完成
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          title: tt('app'),
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF673AB7),
            ),
          ),
          builder: BotToastInit(),
          // 删掉右上角的DEBUG
          debugShowCheckedModeBanner: false,
          navigatorObservers: [BotToastNavigatorObserver()],
          initialRoute: "root",
          routes: {
            "list": (context) => ToolsListPage(),
            "setting": (context) => SettingListPage(),
            "scanner": (context) => ScannerPage(),
            "qrcode": (context) => QRCodePage(),
          },
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', ''), Locale('zh', 'CN')],
          home: const ToolsListPage(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String version = "";

  @override
  void initState() {
    init().then(
      (val) => setState(() {
        version = val;
      }),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => Navigator.pushNamed(context, "list"),
          style: weButtonStyle(Colors.black),
          icon: Icon(Icons.qr_code_2, color: Colors.black, size: 20),
          label: Text(
            tt("list.title"),
            style: TextStyle(fontSize: 16.sp, color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
