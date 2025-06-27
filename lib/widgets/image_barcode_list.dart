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
import 'package:we_tools/services/class_handle_barcode.dart';

class ImageBarcodeList extends StatefulWidget {
  const ImageBarcodeList({
    super.key,
    required this.barcodeCapture,
    this.onClick,
    this.onLongPress,
  });

  final BarcodeCapture barcodeCapture;
  final Function(HandleBarcode hBarcode)? onClick;
  final Function(HandleBarcode hBarcode)? onLongPress;

  @override
  State<ImageBarcodeList> createState() => _ImageBarcodeListState();
}

class _ImageBarcodeListState extends State<ImageBarcodeList> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemCount: widget.barcodeCapture.barcodes.length * 2 - 1,
        itemBuilder: (context, i) {
          if (i % 2 != 0) {
            return const Divider();
          }
          int index = i ~/ 2;
          Barcode v = widget.barcodeCapture.barcodes[index];
          final hb = handleTextSpan(v.rawValue ?? "",urlTap: false);
          return ListTile(
            onTap: widget.onClick == null
                ? null
                : () => widget.onClick!( hb.hBarcode),
            onLongPress:
                widget.onLongPress == null ||
                    v.rawValue == null ||
                    (v.rawValue != null && v.rawValue!.isEmpty)
                ? null
                : () => widget.onLongPress!( hb.hBarcode),
            iconColor: Colors.white,
            textColor: Colors.white,
            title: Text.rich(
              textAlign: TextAlign.left,
              TextSpan(text: "", children: hb.textSpan),
            ),
            trailing: Icon(Icons.arrow_forward_ios),
          );
        },
      ),
    );
  }
}
