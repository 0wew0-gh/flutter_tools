import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class PrettyQRCodeWidget extends StatefulWidget {
  const PrettyQRCodeWidget({super.key, required this.code, this.filePath});

  final String code;
  final String? filePath;

  @override
  State<PrettyQRCodeWidget> createState() => _PrettyQRCodeWidgetState();
}

class _PrettyQRCodeWidgetState extends State<PrettyQRCodeWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PrettyQrView.data(
      data: widget.code,
      decoration: PrettyQrDecoration(
        image:
            widget.filePath == null ||
                (widget.filePath != null && widget.filePath!.isEmpty)
            ? null
            : PrettyQrDecorationImage(image: FileImage(File(widget.filePath!))),
        quietZone: PrettyQrQuietZone.standart,
      ),
    );
  }
}
