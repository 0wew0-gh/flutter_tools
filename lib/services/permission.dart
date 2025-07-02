import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:we_tools/i18n/mytranslate.dart';

Future<bool> checkPermission(BuildContext context, Permission p) async {
  if (await p.isGranted) {
    return true;
  }
  final status = await p
      .onGrantedCallback(() {
        jumpToSystemSetting(context);
      })
      .onPermanentlyDeniedCallback(() {
        jumpToSystemSetting(context);
      })
      .request();
  return status.isGranted;
}

Future<void> jumpToSystemSetting(BuildContext context) async {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(tt("permission.title")),
      content: Text(tt("permission.content")),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(tt("public.cancel")),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await openAppSettings(); // 跳转到设置页
          },
          child: Text(tt("permission.confirm")),
        ),
      ],
    ),
  );
}
