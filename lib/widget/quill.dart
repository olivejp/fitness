import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';

class QuillEditorFlow extends StatefulWidget {
  const QuillEditorFlow({
    super.key,
    required this.width,
    required this.height,
    required this.readOnly,
    required this.initialText,
  });

  final double width;
  final double height;
  final bool readOnly;
  final String initialText;

  @override
  State<QuillEditorFlow> createState() => _QuillEditorFlowState();
}

class _QuillEditorFlowState extends State<QuillEditorFlow> {
  late QuillController _controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!widget.readOnly)
          QuillToolbar.simple(
            configurations: QuillSimpleToolbarConfigurations(
              controller: _controller,
              showRedo: false,
              showFontFamily: false,
              showHeaderStyle: false,
            ),
          ),
        Expanded(
          child: QuillEditor.basic(
            configurations: QuillEditorConfigurations(
              controller: _controller,
              autoFocus: true,
            ),
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = QuillController(
      document: Document.fromJson([
        {'insert': '${widget.initialText}\n'}
      ]),
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: widget.readOnly,
    );

    _controller.document.changes.listen((event) {
      FFAppState().htmlText = event.source.toString();
    });
  }
}
