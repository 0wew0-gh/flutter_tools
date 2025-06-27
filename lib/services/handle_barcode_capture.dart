///-------------------------------------------------------
/// Copyright (c) 2025 0w0
///
/// Licensed under the MIT License.
/// https://opensource.org/licenses/MIT
///
/// Description:
///
///   WeBarcodeOverlay的逻辑层
///-------------------------------------------------------
library;

import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

({List<Widget> widgetList, double zoomVal}) handleBarcodeCapture(
  BuildContext context,
  double sizeZoom,
  BarcodeCapture? barcodeCapture, {
  double iconSize = 50,
  Color iconColor = Colors.white,
  Color backColor = Colors.blue,
  Color nowBackColor = Colors.orange,
  String? nowBarcode,
  Function(String? barcode)? onClick,
}) {
  if (barcodeCapture == null || barcodeCapture.barcodes.isEmpty) {
    return (widgetList: [], zoomVal: sizeZoom);
  }
  final ({double height, double width}) size = (
    height: MediaQuery.of(context).size.height,
    width: MediaQuery.of(context).size.width,
  );
  final double ratio = math.max(
    size.height / barcodeCapture.size.height,
    size.width / barcodeCapture.size.width,
  );

  double zoomVal = sizeZoom;
  final overlays = <Widget>[];
  for (final Barcode barcode in barcodeCapture.barcodes) {
    if (!barcode.size.isEmpty && barcode.corners.isNotEmpty) {
      double zoomtemp = 0.0;
      double sizeRatio = 0.0;
      if (size.width < size.height) {
        sizeRatio = barcode.size.width * ratio;
        zoomtemp = (size.width * sizeZoom) / sizeRatio;
      } else {
        sizeRatio = barcode.size.height * ratio;
        zoomtemp = (size.height * sizeZoom) / sizeRatio;
      }
      zoomtemp *= 0.1;
      if (zoomVal < zoomtemp) {
        zoomVal = zoomtemp;
      }

      final List<Offset> adjustedOffset = [
        for (final offset in barcode.corners)
          Offset(offset.dx * ratio, offset.dy * ratio),
      ];
      final double centerX =
          (adjustedOffset[0].dx + adjustedOffset[2].dx) / 2 -
          (barcodeCapture.size.width * ratio - size.width) / 2 -
          iconSize / 2;
      final double centerY =
          (adjustedOffset[0].dy + adjustedOffset[2].dy) / 2 - iconSize / 2;
      overlays.add(
        Positioned(
          left: centerX,
          top: centerY,
          child: IconButton(
            onPressed: onClick != null ? () => onClick(barcode.rawValue) : null,
            style: ButtonStyle(
              iconColor: WidgetStateProperty.all(iconColor),
              backgroundColor: WidgetStateProperty.all(
                barcode.rawValue == nowBarcode ? nowBackColor : backColor,
              ),
              side: WidgetStateProperty.all(
                BorderSide(width: 4, color: iconColor),
              ),
              shape: WidgetStateProperty.all(CircleBorder()),
              minimumSize: WidgetStateProperty.all(Size(iconSize, iconSize)),
            ),
            tooltip: barcode.rawValue ?? '',
            icon: Icon(Icons.arrow_forward_ios),
          ),
        ),
      );
    }
  }
  return (widgetList: overlays, zoomVal: zoomVal);
}

Future<({File? image, BarcodeCapture? barcodeCapture})> selectImage(
  BuildContext context,
  MobileScannerController controller, {
  double iconSize = 50,
  Color iconColor = Colors.white,
  Color backColor = Colors.blue,
  Color nowBackColor = Colors.orange,
  String? nowBarcode,
  Function(String? barcode)? onClick,
}) async {
  if (kIsWeb) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Analyze image is not supported on web'),
        backgroundColor: Colors.red,
      ),
    );
    return (image: null, barcodeCapture: null);
  }
  final picker = ImagePicker();

  XFile? imagex = await picker.pickImage(source: ImageSource.gallery);
  if (imagex == null) {
    return (image: null, barcodeCapture: null);
  }

  BarcodeCapture? barcodeCapture;
  try {
    barcodeCapture = await controller.analyzeImage(
      imagex.path,
      formats: [BarcodeFormat.unknown, BarcodeFormat.all],
    );
  } on MobileScannerBarcodeException catch (e) {
    print(">>> 111 $e");
  } catch (e) {
    print(">>> $e");
  }
  if (barcodeCapture != null && barcodeCapture.barcodes.isNotEmpty) {
    return (image: File(imagex.path), barcodeCapture: barcodeCapture);
  }

  String imagePath = imagex.path;
  if (Platform.isAndroid) {
    // img.Image? orgImg = await img.decodeImageFile(imagex.path);
    // if (orgImg == null) {
    //   BotToast.showText(text: "Error: 没有找到图片");
    //   return;
    // }
    // String ext = "jpg";
    // print(">>> format:${orgImg.frameType}");

    Directory dir = await getApplicationCacheDirectory();

    String dirPath = p.join(dir.path, "images");
    dir = Directory(dirPath);
    try {
      dir.createSync(recursive: true);
    } catch (e) {
      print(">>> create err: $e");
    }
    int timespamp = DateTime.now().millisecondsSinceEpoch;
    imagePath = p.join(dir.path, "$timespamp.jpg");
    final cmd = img.Command()
      ..decodeImageFile(imagex.path)
      ..copyResize(width: 300)
      ..writeToFile(imagePath);
    await cmd.executeThread();

    print('>>> dirPath: $imagePath');
  }

  try {
    barcodeCapture = await controller.analyzeImage(
      imagePath,
      formats: [BarcodeFormat.unknown, BarcodeFormat.all],
    );
  } on MobileScannerBarcodeException catch (e) {
    print(">>> 111 $e");
  } catch (e) {
    print(">>> $e");
  }
  if (barcodeCapture != null && barcodeCapture.barcodes.isNotEmpty) {
    return (image: File(imagePath), barcodeCapture: barcodeCapture);
  }
  print(">>> img path: $imagePath code :${barcodeCapture!.barcodes}");
  return (image: File(imagePath), barcodeCapture: null);
}

// assets转为文件路径
Future<String> openAsset(String path) async {
  String imagePath = await getAssetPath(path);
  print(">>> imagePath: $imagePath");
  return imagePath;
}

Future<String> getAssetPath(String asset) async {
  final path = await getLocalPath(asset);
  await Directory(p.dirname(path)).create(recursive: true);
  final file = File(path);
  if (!await file.exists()) {
    final byteData = await rootBundle.load(asset);
    await file.writeAsBytes(
      byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      ),
    );
  }
  return file.path;
}

Future<String> getLocalPath(String path) async {
  return '${(await getApplicationSupportDirectory()).path}/$path';
}