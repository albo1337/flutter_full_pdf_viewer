import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_plugin.dart';

class PDFViewerScaffold extends StatefulWidget {
  final PreferredSizeWidget? appBar;
  final String path;
  final bool primary;

  const PDFViewerScaffold({
    Key? key,
    this.appBar,
    required this.path,
    this.primary = true,
  }) : super(key: key);

  @override
  _PDFViewScaffoldState createState() => _PDFViewScaffoldState();
}

class _PDFViewScaffoldState extends State<PDFViewerScaffold> {
  final pdfViwerRef = PDFViewerPlugin();
  Rect? _rect;
  Timer? _resizeTimer;

  @override
  void initState() {
    super.initState();
    pdfViwerRef.close();
  }

  @override
  void dispose() {
    super.dispose();
    pdfViwerRef.close();
    pdfViwerRef.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_rect == null) {
      _rect = _buildRect(context);
      pdfViwerRef.launch(
        widget.path,
        rect: _rect,
      );
    } else {
      final rect = _buildRect(context);
      if (_rect != rect) {
        _rect = rect;
        _resizeTimer?.cancel();
        _resizeTimer = Timer(Duration(milliseconds: 300), () {
          pdfViwerRef.resize(_rect!);
        });
      }
    }
    return new Scaffold(
        appBar: widget.appBar,
        body: const Center(child: const CircularProgressIndicator()));
  }

  Rect _buildRect(BuildContext context) {
    final fullscreen = widget.appBar == null;
    final mediaQuery = MediaQuery.of(context);
    final topPadding = widget.primary ? mediaQuery.padding.top : 0.0;
    final top =
        fullscreen ? 0.0 : widget.appBar!.preferredSize.height + topPadding;
    var height = mediaQuery.size.height - top;
    if (height < 0.0) {
      height = 0.0;
    }

    return Rect.fromLTWH(0.0, top, mediaQuery.size.width, height);
  }
}
