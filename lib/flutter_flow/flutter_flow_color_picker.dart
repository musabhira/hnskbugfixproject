import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

Future<Color?> showFFColorPicker(
  BuildContext context, {
  required Color currentColor,
  bool showRecentColors = false,
  bool allowOpacity = true,
  Color? textColor,
  Color? secondaryTextColor,
  Color? backgroundColor,
  Color? primaryButtonBackgroundColor,
  Color? primaryButtonTextColor,
  Color? primaryButtonBorderColor,
  bool displayAsBottomSheet = false,
}) async {
  Color pickedColor = currentColor;

  Widget colorPicker = SingleChildScrollView(
    child: ColorPicker(
      pickerColor: currentColor,
      onColorChanged: (color) => pickedColor = color,
      pickerAreaHeightPercent: 0.8,
      enableAlpha: allowOpacity,
      displayThumbColor: true,
      showLabel: true,
      paletteType: PaletteType.hsv,
      pickerAreaBorderRadius: const BorderRadius.only(
        topLeft: Radius.circular(2.0),
        topRight: Radius.circular(2.0),
      ),
    ),
  );

  if (displayAsBottomSheet) {
    return await showModalBottomSheet<Color>(
      context: context,
      backgroundColor: backgroundColor ?? Theme.of(context).canvasColor,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: colorPicker,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: secondaryTextColor),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(pickedColor),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryButtonBackgroundColor,
                    foregroundColor: primaryButtonTextColor,
                    side: primaryButtonBorderColor != null
                        ? BorderSide(color: primaryButtonBorderColor)
                        : null,
                  ),
                  child: const Text('Select'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  } else {
    return await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            backgroundColor ?? Theme.of(context).dialogBackgroundColor,
        content: colorPicker,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: secondaryTextColor),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(pickedColor),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryButtonBackgroundColor,
              foregroundColor: primaryButtonTextColor,
              side: primaryButtonBorderColor != null
                  ? BorderSide(color: primaryButtonBorderColor)
                  : null,
            ),
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }
}
