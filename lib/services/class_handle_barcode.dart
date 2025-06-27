import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:we_tools/i18n/mytranslate.dart';
import 'package:we_tools/services/utils.dart';

enum HandleBarcodeType { text, url, wifi }

class HandleBarcode {
  HandleBarcode({
    this.barcode = "",

    this.ssid = "",
    this.password = "",
    this.safety = "",

    this.url = "",
    this.scheme = "",
    this.host = "",
    this.path = "",
    this.parameters = const [],

    this.type = HandleBarcodeType.text,
  });

  /// 源码
  String barcode;

  /// Wi-Fi 信息
  String ssid;

  /// Wi-Fi 密码
  String password;

  /// Wi-Fi 安全性
  String safety;

  /// URL 信息
  String url;

  /// URL 协议
  String scheme;

  /// URL 域名
  String host;

  /// URL 路径
  String path;

  /// URL 参数
  List<String> parameters;

  /// 扫码类型
  HandleBarcodeType type;
}

HandleBarcodeType getBarcodeType(String barCode) {
  if (barCode.toLowerCase().startsWith("wifi:")) {
    return HandleBarcodeType.wifi;
  } else if (barCode.toLowerCase().startsWith("http://") ||
      barCode.toLowerCase().startsWith("https://")) {
    return HandleBarcodeType.url;
  }
  return HandleBarcodeType.text;
}

HandleBarcode handleBarcode(String barCode) {
  HandleBarcode hBarcode = HandleBarcode(barcode: barCode);
  if (barCode.toLowerCase().startsWith("wifi:")) {
    hBarcode.type = HandleBarcodeType.wifi;
    List wifiInfo = barCode.substring(5).split(";");
    for (var wI in wifiInfo) {
      List temp = wI.split(":");
      if (temp.length < 2) {
        continue;
      }
      switch (temp[0]) {
        case "S":
          hBarcode.ssid = temp[1];
          break;
        case "T":
          hBarcode.safety = temp[1];
          break;
        case "P":
          hBarcode.password = temp[1];
          break;
        default:
      }
    }
  } else {
    Uri uri = Uri.parse(barCode);
    if (uri.hasScheme && uri.host.isNotEmpty) {
      hBarcode.type = HandleBarcodeType.url;
      hBarcode.scheme = uri.scheme;
      hBarcode.host = uri.host;
      hBarcode.path = uri.path;
      String query = uri.query;
      if (query.isNotEmpty) {
        hBarcode.parameters = query.split("&");
      }
    }
  }
  return hBarcode;
}

final Color urlColor = const Color(0xFF88C9FF);
({HandleBarcode hBarcode, List<InlineSpan> textSpan}) handleTextSpan(
  String barcode, {
  bool urlTap = true,
}) {
  HandleBarcode hBarcode = handleBarcode(barcode);
  List<InlineSpan> textSpan = [];
  switch (hBarcode.type) {
    case HandleBarcodeType.url:
      textSpan = [
        TextSpan(
          text: hBarcode.barcode,
          style: TextStyle(
            color: urlColor,
            decoration: TextDecoration.underline,
            decorationColor: urlColor,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = urlTap ? () => openUrlForBrowser(hBarcode.barcode) : null,
        ),
      ];
      break;
    case HandleBarcodeType.wifi:
      textSpan = [
        TextSpan(text: '${tt('qrcode.wifi.ssid')}: ${hBarcode.ssid}'),
        TextSpan(text: '\n${tt('qrcode.wifi.pw')}: ${hBarcode.password}'),
        TextSpan(text: '\n${tt('qrcode.wifi.safety')}: ${hBarcode.safety}'),
      ];
      break;
    default:
      textSpan = [TextSpan(text: hBarcode.barcode)];
  }
  return (hBarcode: hBarcode, textSpan: textSpan);
}
