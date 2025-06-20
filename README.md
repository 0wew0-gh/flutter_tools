# flutte tools

自用 Flutter 工具

## 跨页面实时通知

复制文件[notificationCenter.dart](notificationCenter.dart)到项目目录下。

### 订阅

```dart
NotificationCenter.instance.addObserver(
  'postName',
  (object) {
  print(object);
  },
);
```

### 发布

```dart
NotificationCenter.instance.postNotification(
  'postName',
  true,
);
```

### 取消订阅

```dart
NotificationCenter.instance.removeNotification('postName');
```

## 仿支付宝扫码的覆盖层

扫码包 [mobile_scanner](https://pub-web.flutter-io.cn/packages/mobile_scanner) 的覆盖层。

### 初始化`mobile_scanner`

```dart
final MobileScannerController controller = MobileScannerController(
  cameraResolution: size,
  detectionSpeed: detectionSpeed,
  detectionTimeoutMs: detectionTimeout,
  formats: selectedFormats,
  returnImage: returnImage,
  torchEnabled: true,
  invertImage: invertImage,
  autoZoom: autoZoom,
);
```

### 加入覆盖层

复制文件[we_barcode_overlay.dart](we_barcode_overlay.dart) 到项目目录下。

```dart
Stack(
  children: [
    SizedBox(
      height: 100.h,
      child: MobileScanner(
        controller: controller
        fit: boxFit,
      ),
    ),
    if (controller != null)
      WeBarcodeOverlay(
        controller: controller!,
        nowBarcode: scannerString,
        onClick: (barcode) {
          if (barcode == null) {
            return;
          }
          handleBarcoe(barcode);
        },
      ),
  ],
)
```
