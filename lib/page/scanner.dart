import 'dart:async';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sizer/sizer.dart';
import 'package:we_tools/i18n/mytranslate.dart';
import 'package:we_tools/services/class_handle_barcode.dart';
import 'package:we_tools/services/handle_barcode_capture.dart';
import 'package:we_tools/services/utils.dart';
import 'package:we_tools/widgets/handle_btn_group.dart';
import 'package:we_tools/widgets/image_barcode_list.dart';
import 'package:we_tools/widgets/scanner_error_widget.dart';
import 'package:we_tools/widgets/toggle_flashlight_button.dart';
import 'package:we_tools/widgets/we_barcode_overlay.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  MobileScannerController? controller;

  // A scan window does work on web, but not the overlay to preview the scan
  // window. This is why we disable it here for web examples.

  bool autoZoom = false;
  bool invertImage = false;
  bool returnImage = false;

  Size desiredCameraResolution = const Size(19200, 40800);
  DetectionSpeed detectionSpeed = DetectionSpeed.unrestricted;
  int detectionTimeoutMs = 500;

  bool useBarcodeOverlay = true;
  BoxFit boxFit = BoxFit.cover;
  bool enableLifecycle = false;

  /// Hides the MobileScanner widget while the MobileScannerController is
  /// rebuilding
  bool hideMobileScannerWidget = false;

  List<BarcodeFormat> selectedFormats = [BarcodeFormat.all];

  MobileScannerController initController() => MobileScannerController(
    autoStart: false,
    // cameraResolution: desiredCameraResolution,
    detectionSpeed: detectionSpeed,
    detectionTimeoutMs: detectionTimeoutMs,
    formats: selectedFormats,
    returnImage: returnImage,
    // torchEnabled: true,
    invertImage: invertImage,
    autoZoom: autoZoom,
  );

  HandleBarcode hBarcode = HandleBarcode();
  List<InlineSpan> textSpan = [];
  int restoreCount = 0;
  Timer? zoomCountTimer;

  ({File? image, BarcodeCapture? barcodeCapture}) selectImg = (
    image: null,
    barcodeCapture: null,
  );

  @override
  void initState() {
    controller = initController();
    unawaited(controller!.start());
    getBarcodeString();
    super.initState();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await controller?.dispose();
    controller = null;
    if (zoomCountTimer != null) {
      zoomCountTimer!.cancel();
    }
  }

  void getBarcodeString() {
    // 添加计数器没100毫秒执行一次
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      zoomCountTimer = timer;
      if (controller != null && restoreCount >= switchCounter) {
        controller!.setZoomScale(0);
        restoreCount = 0;
        zoomCounter = 0;
        return;
      }
      restoreCount++;
    });

    controller!.barcodes.listen((barcode) {
      final List<String> barcodes = [];
      restoreCount = 0;
      for (final Barcode barcode in barcode.barcodes) {
        if (barcode.rawValue == null) {
          return;
        }
        barcodes.add(barcode.rawValue!);
      }
      if (barcodes.length == 1) {
        final hb = handleTextSpan(barcodes.first);
        setState(() {
          textSpan = hb.textSpan;
          hBarcode = hb.hBarcode;
        });
      }
    });
  }

  void clickSelectImage(BuildContext context, {String imagePath = ""}) async {
    BotToast.showLoading();
    if (imagePath.isNotEmpty) {
      String assetsImgPath = await openAsset(imagePath);
      BarcodeCapture? barcodeCapture = await controller!.analyzeImage(
        assetsImgPath,
        formats: [BarcodeFormat.unknown, BarcodeFormat.all],
      );
      selectImg = (image: File(assetsImgPath), barcodeCapture: barcodeCapture);
    } else {
      selectImg = await selectImage(
        context,
        controller!,
        onClick: (barcode) {
          if (barcode == null) {
            return;
          }
          final hb = handleTextSpan(barcode);
          setState(() {
            textSpan = hb.textSpan;
            hBarcode = hb.hBarcode;
          });
        },
      );
    }
    if (selectImg.barcodeCapture != null &&
        selectImg.barcodeCapture!.barcodes.isNotEmpty) {
      controller!.stop();
    } else if (selectImg.image == null) {
      controller!.start();
    }
    BotToast.closeAllLoading();
    print(">>> clickSelectImage");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: controller == null || hideMobileScannerWidget
          ? const Placeholder()
          : Stack(
              children: [
                SizedBox(
                  height: 100.h,
                  child: MobileScanner(
                    controller: controller,
                    errorBuilder: (context, error) {
                      return ScannerErrorWidget(error: error);
                    },
                    fit: boxFit,
                  ),
                ),
                if (selectImg.barcodeCapture != null)
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 100),
                      child: Container(
                        alignment: Alignment.topCenter,
                        height: 75.h - 100,
                        color: const Color(0x66FFFFFF),
                        child: ImageBarcodeList(
                          barcodeCapture: selectImg.barcodeCapture!,
                          onClick: (hB) {
                            if (hB.barcode.isEmpty) {
                              BotToast.showText(text: tt('Error.url null'));
                              return;
                            }
                            switch (hB.type) {
                              case HandleBarcodeType.wifi:
                                copyToClipboard(
                                  hBarcode.password,
                                  successTip: tt("qrcode.copyPWSuccess"),
                                );
                                break;
                              default:
                                copyToClipboard(hB.barcode);
                                break;
                            }
                          },
                          onLongPress: (hB) async {
                            if (hB.barcode.isEmpty) {
                              BotToast.showText(text: tt('Error.url null'));
                              return;
                            }
                            switch (hB.type) {
                              case HandleBarcodeType.url:
                                openUrlForBrowser(hB.barcode);
                                break;
                              case HandleBarcodeType.wifi:
                                copyToClipboard(
                                  '${tt('qrcode.wifi.ssid')}: ${hB.ssid}\n${tt('qrcode.wifi.pw')}: ${hB.password}\n${tt('qrcode.wifi.safety')}: ${hB.safety}',
                                );
                                break;
                              default:
                                copyToClipboard(hB.barcode);
                                break;
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: selectImg.image != null
                      ? Container(
                          alignment: Alignment.bottomCenter,
                          height: 25.h,
                          color: const Color(0x6600 + 0000),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Image.file(selectImg.image!),
                              ),
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  IconButton(
                                    color: Colors.white,
                                    tooltip: tt('qrcode.selectImage'),
                                    icon: Icon(Icons.image),
                                    iconSize: 32,
                                    onPressed: () => clickSelectImage(context),
                                  ),
                                  if (selectImg.image != null &&
                                      controller != null)
                                    IconButton(
                                      onPressed: () async {
                                        BarcodeCapture? barcodeCapture =
                                            await controller!.analyzeImage(
                                              selectImg.image!.path,
                                              formats: [
                                                BarcodeFormat.unknown,
                                                BarcodeFormat.all,
                                              ],
                                            );
                                        if (barcodeCapture != null &&
                                            barcodeCapture
                                                .barcodes
                                                .isNotEmpty) {
                                          selectImg = (
                                            image: selectImg.image!,
                                            barcodeCapture: barcodeCapture,
                                          );
                                        }
                                        setState(() {});
                                      },
                                      color: Colors.white,
                                      iconSize: 32,
                                      tooltip: tt('qrcode.reScan'),
                                      icon: Icon(Icons.refresh),
                                    ),
                                  IconButton(
                                    onPressed: () {
                                      selectImg = (
                                        barcodeCapture: null,
                                        image: null,
                                      );
                                      setState(() {});
                                      controller!.start();
                                    },
                                    color: Colors.redAccent,
                                    iconSize: 32,
                                    tooltip: tt('public.cancel'),
                                    icon: Icon(Icons.close),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : Container(
                          color: const Color(0x66000000),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: DefaultSelectionStyle(
                                  selectionColor: const Color(
                                    0xA9854AEC,
                                  ), // 选中文字背景色
                                  child: SelectableText.rich(
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.sp,
                                    ),
                                    TextSpan(text: "", children: textSpan),
                                  ),
                                ),

                                //  Text(
                                //   scannerString,
                                //   textAlign: TextAlign.center,
                                //   softWrap: true,
                                //   overflow: TextOverflow.visible,
                                //   style: const TextStyle(
                                //     color: Colors.white,
                                //     fontSize: 16,
                                //   ),
                                // ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  SizedBox(width: 50),
                                  if (hBarcode.barcode.isNotEmpty)
                                    HandleBtnGroup(hBarcode: hBarcode),
                                  IconButton(
                                    color: Colors.white,
                                    tooltip: tt('qrcode.selectImage'),
                                    icon: Icon(Icons.image),
                                    iconSize: 32,
                                    onPressed: () => clickSelectImage(context),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                ),

                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    height: 100,
                    color: const Color.fromRGBO(0, 0, 0, 0.4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          color: Colors.white,
                          iconSize: 32,
                          icon: const Icon(Icons.arrow_back_ios_new),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        ToggleFlashlightButton(controller: controller!),
                      ],
                    ),
                  ),
                ),

                if (useBarcodeOverlay && controller != null)
                  WeBarcodeOverlay(
                    controller: controller!,
                    nowBarcode: hBarcode.barcode,
                    onClick: (barcode) {
                      if (barcode == null) {
                        return;
                      }
                      final hb = handleTextSpan(barcode);
                      setState(() {
                        textSpan = hb.textSpan;
                        hBarcode = hb.hBarcode;
                      });
                    },
                  ),
              ],
            ),
    );
  }
}
