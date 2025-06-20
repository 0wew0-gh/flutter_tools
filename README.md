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

