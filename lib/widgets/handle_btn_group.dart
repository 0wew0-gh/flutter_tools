import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:we_tools/i18n/mytranslate.dart';
import 'package:we_tools/services/class_handle_barcode.dart';
import 'package:we_tools/services/utils.dart';

class HandleBtnGroup extends StatefulWidget {
  const HandleBtnGroup({super.key, required this.hBarcode});

  final HandleBarcode hBarcode;

  @override
  State<HandleBtnGroup> createState() => _HandleBtnGroupState();
}

class _HandleBtnGroupState extends State<HandleBtnGroup> {
  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = [];

    switch (widget.hBarcode.type) {
      case HandleBarcodeType.url:
        widgetList.add(
          ElevatedButton(
            onPressed: () => copyToClipboard(widget.hBarcode.barcode),
            style: weButtonStyle(Colors.white),
            child: Text(
              tt("public.copy"),
              style: TextStyle(fontSize: 16.sp, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        );
        widgetList.add(SizedBox(width: 8));
        widgetList.add(
          ElevatedButton(
            onPressed: () => openUrlForBrowser(widget.hBarcode.barcode),
            style: weButtonStyle(Colors.white),
            child: Text(
              tt("public.useSystem"),
              style: TextStyle(fontSize: 16.sp, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        );
        break;
      case HandleBarcodeType.wifi:
        widgetList.add(
          ElevatedButton(
            onPressed: () => copyToClipboard(
              '${tt('qrcode.wifi.ssid')}: ${widget.hBarcode.ssid}\n${tt('qrcode.wifi.pw')}: ${widget.hBarcode.password}\n${tt('qrcode.wifi.safety')}: ${widget.hBarcode.safety}',
            ),
            style: weButtonStyle(Colors.white),
            child: Text(
              tt("public.copy"),
              style: TextStyle(fontSize: 16.sp, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        );
        widgetList.add(SizedBox(width: 8));
        widgetList.add(
          ElevatedButton(
            onPressed: () => copyToClipboard(widget.hBarcode.password),
            style: weButtonStyle(Colors.white),
            child: Text(
              tt("qrcode.copyPassword"),
              style: TextStyle(fontSize: 16.sp, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        );
        break;

      default:
        widgetList.add(
          ElevatedButton(
            onPressed: () => copyToClipboard(widget.hBarcode.barcode),
            style: weButtonStyle(Colors.white),
            child: Text(
              tt("public.copy"),
              style: TextStyle(fontSize: 16.sp, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: widgetList,
    );
  }
}
