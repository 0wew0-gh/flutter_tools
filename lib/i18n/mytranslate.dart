import 'dart:convert';

import 'package:we_tools/global.dart';

import 'en.dart';
import 'zhcn.dart';
// import 'zhtw.dart';

String tt(String key) {
  Map tmap = {};
  switch (Global.i.locale) {
    case 'en':
      tmap = en;
      break;
    case 'zh':
    case 'zh-TW':
    case 'zh_TW':
    case 'zh-CN':
    case 'zh_CN':
      tmap = zhcn;
      break;
    // case 'zh-TW':
    // case 'zh_TW':
    //   tmap = zhtw;
    //   break;
    // case 'es':
    //   tmap = es;
    // break;
    default:
      tmap = en;
  }
  List tarr = [];
  tarr.addAll(key.split("."));
  String returnstr = "";
  for (var i = 0; i < tarr.length; i++) {
    if (tmap.containsKey(tarr[i])) {
      if (tarr.length - 1 == i) {
        Object temp = tmap[tarr[i]];
        if (temp is String) {
          returnstr = temp;
        } else {
          returnstr = jsonEncode(temp);
        }
      } else {
        tmap = tmap[tarr[i]];
      }
    } else {
      return key;
    }
  }
  return returnstr;
}
