import 'package:flutter/material.dart';
import 'package:we_tools/i18n/mytranslate.dart';
import 'package:we_tools/services/utils.dart';

class ToolsListPage extends StatefulWidget {
  const ToolsListPage({super.key});

  @override
  State<ToolsListPage> createState() => _ToolsListPageState();
}

class _ToolsListPageState extends State<ToolsListPage> {
  @override
  void initState() {
    init();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tt('app')),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, "setting"),
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            onTap: () => Navigator.pushNamed(context, "scanner"),
            leading: Icon(Icons.qr_code_scanner, size: 50),
            trailing: Icon(Icons.arrow_forward_ios, size: 20),
            title: Text(tt('list.qrcodeScan')),
          ),
          ListTile(
            onTap: () => Navigator.pushNamed(context, "qrcode"),
            leading: Icon(Icons.qr_code_2, size: 50),
            trailing: Icon(Icons.arrow_forward_ios, size: 20),
            title: Text(tt('list.qrcodeGenerate')),
          ),
        ],
      ),
    );
  }
}
