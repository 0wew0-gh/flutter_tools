///-------------------------------------------------------
/// Copyright (c) 2025 0w0
///
/// Licensed under the MIT License.
/// https://opensource.org/licenses/MIT
///
/// Description:
///
///   mobile_scanner使用的BarcodeOverlay。
///
///   仿支付宝的扫描覆盖层
///-------------------------------------------------------
library;

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:we_tools/services/handle_barcode_capture.dart';

int zoomCounter = 0;
final int switchCounter = 20;

class WeBarcodeOverlay extends StatefulWidget {
  const WeBarcodeOverlay({
    super.key,
    required this.controller,
    this.nowBarcode,
    this.autoPause = false,
    this.iconSize = 50,
    this.iconColor = Colors.white,
    this.backColor = Colors.blue,
    this.nowBackColor = Colors.orange,
    this.onClick,
  });

  final MobileScannerController controller;

  final String? nowBarcode;

  final bool autoPause;

  final double iconSize;
  final Color iconColor;
  final Color backColor;
  final Color nowBackColor;
  final Function(String? barcode)? onClick;

  @override
  State<WeBarcodeOverlay> createState() => _WeBarcodeOverlayState();
}

class _WeBarcodeOverlayState extends State<WeBarcodeOverlay> {
  final double sizeZoom = 0.98;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, value, child) {
        if (!value.isInitialized || !value.isRunning || value.error != null) {
          return const SizedBox();
        }

        return StreamBuilder<BarcodeCapture>(
          stream: widget.controller.barcodes,
          builder: (context, snapshot) {
            final BarcodeCapture? barcodeCapture = snapshot.data;

            final handleBC = handleBarcodeCapture(
              context,
              value.zoomScale,
              barcodeCapture,
              iconSize: widget.iconSize,
              iconColor: widget.iconColor,
              backColor: widget.backColor,
              nowBackColor: widget.nowBackColor,
              nowBarcode: widget.nowBarcode,
              onClick: widget.onClick,
            );
            double zoomVal = handleBC.zoomVal;
            if (zoomCounter >= switchCounter) {
              if (handleBC.widgetList.isEmpty) {
                zoomVal = 0.0;
              }
              widget.controller.setZoomScale(zoomVal);
              zoomCounter = 0;
            }
            if (widget.autoPause) {
              widget.controller.stop();
            }
            zoomCounter++;
            return Stack(fit: StackFit.expand, children: handleBC.widgetList);
          },
        );
      },
    );
  }
}
