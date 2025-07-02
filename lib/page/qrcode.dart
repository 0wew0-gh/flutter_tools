import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import 'package:we_tools/i18n/mytranslate.dart';
import 'package:we_tools/services/handle_barcode_capture.dart';
import 'package:we_tools/services/permission.dart';
import 'package:we_tools/widgets/pretty_qr_code.dart';

class QRCodePage extends StatefulWidget {
  const QRCodePage({super.key});

  @override
  State<QRCodePage> createState() => _QRCodePageState();
}

class _QRCodePageState extends State<QRCodePage> {
  TextEditingController qrCodeController = TextEditingController();

  final GlobalKey qrCodeKey = GlobalKey();

  String qrCodeStr = "";
  bool useImage = false;
  String imgPath = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
  }

  Future<String> clickSelectImage() async {
    final picker = ImagePicker();
    XFile? imagex = await picker.pickImage(source: ImageSource.gallery);
    if (imagex == null) {
      return "";
    }
    return imagex.path;
  }

  Future<void> capturePng(BuildContext context) async {
    bool status = false;
    if (Platform.isAndroid) {
      status = await checkPermission(context, Permission.storage);
    } else if (Platform.isIOS) {
      status = await checkPermission(context, Permission.photos);
    }
    if (!status) {
      BotToast.showText(text: "没有权限");
      return;
    }

    try {
      // 1. 获取 RepaintBoundary 对象
      RenderRepaintBoundary boundary =
          qrCodeKey.currentContext!.findRenderObject() as RenderRepaintBoundary;


      // 2. 转换为 image
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      // 3. 转换为 ByteData（PNG 格式）
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // 保存到临时文件
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/we_qrcode_${DateTime.now().toIso8601String()}.png';
      File imgFile = File(filePath);
      await imgFile.writeAsBytes(pngBytes);
      // 4
      // 保存到相册
      final result = await ImageGallerySaverPlus.saveFile(imgFile.path);

      print(">>> save result: $result");
      BotToast.showText(text: tt("qrcode.saveSuccess"));
    } catch (e) {
      print(">>> ${tt("qrcode.saveError")}: $e");
      BotToast.showText(text: "${tt("qrcode.saveError")}: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tt("list.qrcodeGenerate")),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          TextField(
            controller: qrCodeController,
            decoration: InputDecoration(
              suffixIcon: qrCodeController.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        qrCodeController.clear();
                        qrCodeStr = "";
                        setState(() {});
                      },
                      tooltip: tt('public.clear'),
                      icon: Transform.rotate(
                        angle: math.pi * 0.25,
                        child: Icon(Icons.add_circle_sharp, color: Colors.grey),
                      ),
                    ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() {
              useImage = !useImage;
            }),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: useImage,
                  onChanged: (val) {
                    if (val == null) {
                      return;
                    }
                    setState(() {
                      useImage = val;
                    });
                  },
                ),
                Text(tt("qrcode.useImage")),
              ],
            ),
          ),
          if (useImage)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 50.w,
                  height: 50.w,
                  child: imgPath.isEmpty
                      ? Container()
                      : Image.file(File(imgPath), fit: BoxFit.contain),
                ),

                ElevatedButton(
                  onPressed: () async {
                    imgPath = await clickSelectImage();
                    setState(() {});
                  },
                  style: ButtonStyle(elevation: WidgetStateProperty.all(0)),
                  child: Text(tt("qrcode.selectImage")),
                ),
              ],
            ),
          ElevatedButton(
            onPressed: () async {
              if (imgPath.isEmpty) {
                imgPath = await openAsset('assets/logo.png');
              }
              setState(() {
                qrCodeStr = qrCodeController.text;
              });
            },
            child: Text(tt("qrcode.generate")),
          ),
          SizedBox(
            width: 100.w - 30,
            height: 100.w - 30,
            child: qrCodeStr.isEmpty
                ? Container()
                : Center(
                    child: RepaintBoundary(
                      key: qrCodeKey,
                      child: PrettyQRCodeWidget(
                        code: qrCodeStr,
                        filePath: useImage ? imgPath : null,
                      ),
                    ),
                  ),
          ),
          ElevatedButton(
            onPressed: () => capturePng(context),
            child: Text(tt("qrcode.save")),
          ),
        ],
      ),
    );
  }
}
