import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:we_tools/global.dart';
import 'package:we_tools/i18n/mytranslate.dart';
import 'package:we_tools/services/utils.dart';

class SettingListPage extends StatefulWidget {
  const SettingListPage({super.key});

  @override
  State<SettingListPage> createState() => _SettingListPageState();
}

class _SettingListPageState extends State<SettingListPage> {
  late Completer<int> completer;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tt("setting"), style: TextStyle(fontSize: 18.sp)),
      ),
      body: ListView(
        children: [
          /// 语言
          Semantics(
            button: true,
            child: ListTile(
              leading: const Icon(Icons.language),
              title: Text(
                tt("Languages.current"),
                style: TextStyle(fontSize: 16.sp),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    Global.i.followSystem
                        ? tt("Languages.followSystem")
                        : tt("language"),
                    style: TextStyle(color: Colors.grey[700], fontSize: 16.sp),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 18,
                  ),
                ],
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Semantics(
                        header: true,
                        readOnly: true,
                        child: Text(
                          tt("Languages.change"),
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Semantics(
                            label: tt("Languages.change"),
                            button: true,
                            child: ListTile(
                              title: Text(
                                tt("Languages.followSystem"),
                                style: TextStyle(fontSize: 16.sp),
                              ),
                              onTap: () => setLocale(true, "").then((value) {
                                if (!mounted) {
                                  return;
                                }
                                Navigator.pop(context);
                              }),
                            ),
                          ),
                          Semantics(
                            label: tt("Languages.change"),
                            button: true,
                            child: ListTile(
                              title: Text(
                                "简体中文",
                                style: TextStyle(fontSize: 16.sp),
                              ),
                              onTap: () =>
                                  setLocale(false, "zh-CN").then((value) {
                                    if (!mounted) {
                                      return;
                                    }
                                    Navigator.pop(context);
                                  }),
                            ),
                          ),
                          // ListTile(
                          //   title: const Text("繁体中文"),
                          //   onTap: () => f.setLocale(false, "zh-TW").then(
                          //         (value) => Navigator.pop(context),
                          //       ),
                          // ),
                          Semantics(
                            label: tt("Languages.change"),
                            button: true,
                            child: ListTile(
                              title: Text(
                                "English",
                                style: TextStyle(fontSize: 16.sp),
                              ),
                              onTap: () => setLocale(false, "en").then((value) {
                                if (!mounted) {
                                  return;
                                }
                                Navigator.pop(context);
                              }),
                            ),
                          ),
                          Semantics(
                            label: tt("Languages.change"),
                            button: true,
                            child: ListTile(
                              title: Text(
                                "Español",
                                style: TextStyle(fontSize: 16.sp),
                              ),
                              onTap: () => setLocale(false, "es").then((value) {
                                if (!mounted) {
                                  return;
                                }
                                Navigator.pop(context);
                              }),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ).then((value) {
                  getLanguageID().then((val) {
                    setState(() {});
                  });
                });
              },
            ),
          ),

          /// 恢复设置
          Semantics(
            button: true,
            child: ListTile(
              leading: const Icon(Icons.cleaning_services),
              title: Text(
                tt("public.clear"),
                style: TextStyle(fontSize: 16.sp),
              ),
              trailing: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
                ],
              ),
              onTap: () => BotToast.showCustomLoading(
                toastBuilder: (Function() cancelFunc) {
                  return AlertDialog(
                    title: Text(tt('public.checkClear')),
                    actions: [
                      TextButton(
                        onPressed: () => cancelFunc(),
                        child: Text(tt('public.cancel')),
                      ),
                      TextButton(
                        onPressed: () async {
                          SharedPreferences sp =
                              await SharedPreferences.getInstance();
                          await sp.clear();
                          cancelFunc();
                        },
                        child: Text(
                          tt('public.clear'),
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          /// 关于
          Semantics(
            button: true,
            child: ListTile(
              leading: const Icon(Icons.priority_high_rounded),
              title: Text(tt("version"), style: TextStyle(fontSize: 16.sp)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    Global.i.packageInfo[0],
                    style: TextStyle(color: Colors.grey[700], fontSize: 16.sp),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 18,
                  ),
                ],
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (context, mSetState) {
                        return AboutDialog(
                          applicationName: tt("app"),
                          applicationIcon: Semantics(
                            label: "Logo",
                            image: true,
                            focusable: false,
                            child: SizedBox(
                              width: 40,
                              child: Image.asset(
                                "assets/logo.png",
                                semanticLabel: "Logo",
                              ),
                            ),
                          ),
                          applicationVersion:
                              "${Global.i.packageInfo[0]} (${Global.i.packageInfo[1]})",
                          applicationLegalese: "© 2023 Tongdy",
                          children: <Widget>[
                            // Center(
                            //   child: GestureDetector(
                            //     onTap: () => Global.i.jumpUrL(
                            //       host: tt("url.host"),
                            //       path: tt("url.eulaURL"),
                            //     ),
                            //     child: Padding(
                            //       padding: const EdgeInsets.all(8.0),
                            //       child: Text(
                            //         tt("url.eula"),
                            //         style: TextStyle(
                            //           fontSize: 16.sp,
                            //           decoration: TextDecoration.underline,
                            //           color: Colors.blue,
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            // Center(
                            //   child: GestureDetector(
                            //     onTap: () => Global.i.jumpUrL(
                            //       host: tt("url.host"),
                            //       path: tt("url.privacyURL"),
                            //     ),
                            //     child: Padding(
                            //       padding: const EdgeInsets.all(8.0),
                            //       child: Text(
                            //         tt("url.privacy"),
                            //         style: TextStyle(
                            //           fontSize: 16.sp,
                            //           decoration: TextDecoration.underline,
                            //           color: Colors.blue,
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            // if (getDeviceCountry())
                            //   Center(
                            //     child: GestureDetector(
                            //       onTap: () => Global.i.jumpUrL(
                            //         host: "beian.miit.gov.cn",
                            //       ),
                            //       child: Padding(
                            //         padding: const EdgeInsets.all(8.0),
                            //         child: Text(
                            //           "京ICP备18012125号-5A",
                            //           style: TextStyle(
                            //             fontSize: 16.sp,
                            //             decoration: TextDecoration.underline,
                            //             color: Colors.blue,
                            //           ),
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                          ],
                        );
                      },
                    );
                  },
                ).then((value) => print(">>> AboutDialog: $value"));
              },
            ),
          ),
        ],
      ),
    );
  }
}
