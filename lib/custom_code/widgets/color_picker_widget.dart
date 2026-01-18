// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_color_picker.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

class ColorPickerWidget extends StatefulWidget {
  final Color? initialColor;
  final String label;
  final String? initialColorCode;
  final Function(Color, String) onColorSelected;
  final double width;
  final double height;

  const ColorPickerWidget({
    required this.width,
    required this.height,
    required this.label,
    super.key,
    this.initialColor,
    this.initialColorCode,
    required this.onColorSelected,
  });

  @override
  _ColorPickerWidgetState createState() => _ColorPickerWidgetState();
}

class _ColorPickerWidgetState extends State<ColorPickerWidget> {
  Color? _selectedColor;
  String? _colorCode;

  @override
  void initState() {
    super.initState();
    // Initialize with the passed initial color and color code
    _colorCode = widget.initialColorCode;
    _selectedColor = widget.initialColor ??
        (_colorCode != null ? _parseColorFromHex(_colorCode!) : null);
  }

  Future<void> _pickColor(BuildContext context) async {
    // Replace with your actual color picker implementation
    final pickedColor = await showFFColorPicker(
      context,
      currentColor: _selectedColor ?? Colors.blue,
      showRecentColors: true,
      allowOpacity: true,
      textColor: FlutterFlowTheme.of(context).primaryText,
      secondaryTextColor: FlutterFlowTheme.of(context).secondaryText,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      primaryButtonBackgroundColor: FlutterFlowTheme.of(context).primary,
      primaryButtonTextColor: Colors.white,
      primaryButtonBorderColor: Colors.transparent,
      displayAsBottomSheet: true,
    );

    if (pickedColor != null) {
      safeSetState(() {
        _selectedColor = pickedColor;
        _colorCode =
            '#${pickedColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
      });
      widget.onColorSelected(pickedColor, _colorCode!);
    }
  }

  Color _parseColorFromHex(String hexCode) {
    final buffer = StringBuffer();
    if (hexCode.length == 6 || hexCode.length == 7) buffer.write('ff');
    buffer.write(hexCode.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 16.0),
      child: GestureDetector(
        onTap: () => _pickColor(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Montserrat',
                    letterSpacing: 0.0,
                  ),
            ),
            Container(
              height: 60.0,
              margin: const EdgeInsets.only(top: 8.0),
              decoration: BoxDecoration(
                color: _selectedColor ??
                    widget.initialColor ??
                    FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(4.0),
                border: Border.all(
                  color: FlutterFlowTheme.of(context).alternate,
                  width: 1.0,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _colorCode ?? 'Pick a color',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Montserrat',
                          fontSize: 16.0,
                        ),
                  ),
                  Container(
                      width: 24.0,
                      height: 24.0,
                      decoration: BoxDecoration(
                        color: _selectedColor ??
                            FlutterFlowTheme.of(context).primary,
                        borderRadius: BorderRadius.circular(4.0),
                        border: Border.all(
                          color: Colors.black,
                          width: 1.0,
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ColorPickerService {
  static Future<Color?> colorBottomSheet(
    BuildContext context, {
    required Color currentColor,
  }) async {
    final pickedColor = await showFFColorPicker(
      context,
      currentColor: currentColor,
      showRecentColors: true,
      allowOpacity: true,
      textColor: FlutterFlowTheme.of(context).primaryText,
      secondaryTextColor: FlutterFlowTheme.of(context).secondaryText,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      primaryButtonBackgroundColor: FlutterFlowTheme.of(context).primary,
      primaryButtonTextColor: Colors.white,
      primaryButtonBorderColor: Colors.transparent,
      displayAsBottomSheet: true,
    );

    return pickedColor;
  }
}
