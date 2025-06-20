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

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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

            if (barcodeCapture == null ||
                barcodeCapture.size.isEmpty ||
                barcodeCapture.barcodes.isEmpty) {
              return const SizedBox();
            }
            final double ratio = math.max(
              MediaQuery.of(context).size.height / barcodeCapture.size.height,
              MediaQuery.of(context).size.width / barcodeCapture.size.width,
            );

            final overlays = <Widget>[];
            for (final Barcode barcode in barcodeCapture.barcodes) {
              if (!barcode.size.isEmpty && barcode.corners.isNotEmpty) {
                final List<Offset> adjustedOffset = [
                  for (final offset in barcode.corners)
                    Offset(offset.dx * ratio, offset.dy * ratio),
                ];
                final double centerX =
                    (adjustedOffset[0].dx + adjustedOffset[2].dx) / 2 -
                    (barcodeCapture.size.width * ratio -
                            MediaQuery.of(context).size.width) /
                        2 -
                    widget.iconSize / 2;
                final double centerY =
                    (adjustedOffset[0].dy + adjustedOffset[2].dy) / 2 -
                    widget.iconSize / 2;
                overlays.add(
                  Positioned(
                    left: centerX,
                    top: centerY,
                    child: IconButton(
                      onPressed: widget.onClick != null
                          ? () => widget.onClick!(barcode.rawValue)
                          : null,
                      style: ButtonStyle(
                        iconColor: WidgetStateProperty.all(widget.iconColor),
                        backgroundColor: WidgetStateProperty.all(
                          barcode.rawValue == widget.nowBarcode
                              ? widget.nowBackColor
                              : widget.backColor,
                        ),
                        side: WidgetStateProperty.all(
                          BorderSide(width: 4, color: widget.iconColor),
                        ),
                        shape: WidgetStateProperty.all(CircleBorder()),
                        minimumSize: WidgetStateProperty.all(
                          Size(widget.iconSize, widget.iconSize),
                        ),
                      ),
                      tooltip: barcode.rawValue ?? '',
                      icon: Icon(Icons.arrow_forward_ios),
                    ),
                  ),
                );
              }
            }
            if (widget.autoPause) {
              widget.controller.stop();
            }
            return Stack(fit: StackFit.expand, children: overlays);
          },
        );
      },
    );
  }
}
