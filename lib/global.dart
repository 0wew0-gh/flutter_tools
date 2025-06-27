import 'package:flutter/material.dart';

class Global {
  /// 是否跟随系统语言
  bool followSystem = true;

  /// 语言
  String locale = "zh_CN";
  String localeTag = "US";
  String timeZone = "Asia/Shanghai";
  
  /// 版本信息
  ///
  /// [0] 版本號
  ///
  /// [1] build 號
  ///
  /// [2] 包名
  ///
  /// [3] 應用名
  List<String> packageInfo = ["", "", "", ""];

  GlobalKey key = GlobalKey();

  static final Global i = Global._internal();
  factory Global() {
    return i;
  }
  Global._internal() {
    // 此處進行初始化操作
  }

  // 十进制转十六进制字节数组
  List<int> tenToSixteen(int value, int length) {
    List<int> list = [];
    for (var i = 0; i < length; i++) {
      int a = (value >> (i * 8)) & 0xff;
      list.add(a);
    }
    return list;
  }

  /// 十六进制字节数组转十进制
  int sixteenToTen(List<int> value) {
    int a = 0;
    for (var i = 0; i < value.length; i++) {
      a += value[i] << (i * 8);
    }
    return a;
  }
}
