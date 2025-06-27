import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:we_tools/global.dart';
import 'package:we_tools/i18n/mytranslate.dart';

/// 设置语言
Future<void> setLocale(
  bool isfollowSystem,
  String localeStr, {
  bool mounted = true,
  Function(dynamic Function())? setState,
}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Locale locale = WidgetsBinding.instance.platformDispatcher.locale;
  if (isfollowSystem) {
    prefs.remove("locale");
    prefs.setBool("followSystem", isfollowSystem);
    Global.i.followSystem = isfollowSystem;
    if (Global.i.locale != locale.toLanguageTag()) {
      Global.i.locale = locale.toLanguageTag();
    }
  } else {
    prefs.setBool("followSystem", isfollowSystem);
    prefs.setString("locale", localeStr);
    Global.i.followSystem = isfollowSystem;
    Global.i.locale = localeStr;
  }
  Global.i.localeTag = locale.countryCode ?? "";
}

// /// 获取设备国家，返回是否是大陆地区
// bool getDeviceCountry() {
//   switch (Global.i.localeTag) {
//     case "TW":
//     case "HK":
//     case "MO":
//     case "CN":
//       return true;
//     default:
//   }
//   return false;
// }

/// 获取语言ID
Future<void> getLanguageID() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? tempbool = prefs.getBool("followSystem");
  if (tempbool != null) {
    Global.i.followSystem = tempbool;
  }
  String? tempstr;
  late Locale locale;
  if (!Global.i.followSystem) {
    tempstr = prefs.getString("locale");
    if (tempstr != null) {
      Global.i.locale = tempstr;
    }
    locale = Locale(Global.i.locale);
    Global.i.localeTag = locale.countryCode ?? "";
  } else {
    locale = WidgetsBinding.instance.platformDispatcher.locale;
    Global.i.locale = locale.languageCode;
    Global.i.localeTag = locale.countryCode ?? "";
  }
  print(">>>>>>>>>>>>>>>>>>");
  print(">>> followSystem: ${Global.i.followSystem}");
  print(">>> locale: ${Global.i.locale}");
  print(">>> localeTag: ${Global.i.localeTag}");
  print(">>> timeZone: ${Global.i.timeZone}");
  print(">>>>>>>>>>>>>>>>>>");
}

// /// 获取时区
// Future<String> getTimeZone() async {
//   return await FlutterTimezone.getLocalTimezone();
// }

ButtonStyle weButtonStyle(Color color) {
  return ButtonStyle(
    side: WidgetStateProperty.all(BorderSide(color: color, width: 1)),
    backgroundColor: WidgetStateColor.resolveWith(
      (states) => color.withValues(alpha: 0.1),
    ),
    padding: WidgetStateProperty.all(
      const EdgeInsets.symmetric(vertical: 15.0, horizontal: 32.0),
    ),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
    ),
    elevation: WidgetStateProperty.all(0),
  );
}

void copyToClipboard(String scannerString, {String successTip = ""}) {
  try {
    Clipboard.setData(ClipboardData(text: scannerString));
  } catch (e) {
    BotToast.showText(
      text: "${tt('Error.copy')}\n$e",
      duration: Duration(seconds: 10),
      align: Alignment(0, 0.6),
    );
    return;
  }

  BotToast.showText(
    text: successTip.isEmpty ? tt('qrcode.copySuccess') : successTip,
    align: Alignment(0, 0.6),
  );
}

Future<void> openUrlForBrowser(String url) async {
  final uri = Uri.parse(url);

  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    BotToast.showText(text: '${tt('Error.open')}$url');
  }
}
