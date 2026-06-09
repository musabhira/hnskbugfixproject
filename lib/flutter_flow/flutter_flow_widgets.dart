import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
// For kDebugMode if needed? No.
import 'package:auto_size_text/auto_size_text.dart';
export 'flutter_flow_icon_button.dart';
export 'flutter_flow_choice_chips.dart';

enum IconAlignment { start, end }

class FFButtonOptions {
  const FFButtonOptions({
    this.textAlign,
    this.textStyle,
    this.elevation,
    this.height,
    this.width,
    this.padding,
    this.color,
    this.disabledColor,
    this.disabledTextColor,
    this.splashColor,
    this.iconSize,
    this.iconColor,
    this.iconAlignment,
    this.iconPadding,
    this.borderRadius,
    this.borderSide,
    this.hoverColor,
    this.hoverBorderSide,
    this.hoverTextColor,
    this.hoverElevation,
    this.maxLines,
  });

  final TextAlign? textAlign;
  final TextStyle? textStyle;
  final double? elevation;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? disabledColor;
  final Color? disabledTextColor;
  final int? maxLines;
  final Color? splashColor;
  final double? iconSize;
  final Color? iconColor;
  final IconAlignment? iconAlignment;
  final EdgeInsetsGeometry? iconPadding;
  final BorderRadius? borderRadius;
  final BorderSide? borderSide;
  final Color? hoverColor;
  final BorderSide? hoverBorderSide;
  final Color? hoverTextColor;
  final double? hoverElevation;
}

class FFButtonWidget extends StatefulWidget {
  const FFButtonWidget({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.iconData,
    required this.options,
    this.showLoadingIndicator = true,
    this.focusNode,
  });

  final String text;
  final Widget? icon;
  final IconData? iconData;
  final Function()? onPressed;
  final FFButtonOptions options;
  final bool showLoadingIndicator;
  final FocusNode? focusNode;

  @override
  State<FFButtonWidget> createState() => _FFButtonWidgetState();
}

class _FFButtonWidgetState extends State<FFButtonWidget> {
  bool loading = false;
  late FocusNode _internalFocusNode;

  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode;

  int get maxLines => widget.options.maxLines ?? 1;
  String? get text =>
      widget.options.textStyle?.fontSize == 0 ? null : widget.text;

  @override
  void initState() {
    super.initState();
    _internalFocusNode = FocusNode();
  }

  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  @override
  void dispose() {
    _internalFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget textWidget = loading
        ? SizedBox(
            width: widget.options.width == null
                ? _getTextWidth(text, widget.options.textStyle, maxLines)
                : null,
            child: Center(
              child: SizedBox(
                width: 23,
                height: 23,
                child: CircularProgressIndicator(
                  color: widget.options.textStyle?.color ?? Colors.white,
                  strokeWidth: 2.5,
                ),
              ),
            ),
          )
        : AutoSizeText(
            text ?? '',
            style:
                text == null ? null : widget.options.textStyle?.withoutColor(),
            textAlign: widget.options.textAlign,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          );

    final onPressed = widget.onPressed != null
        ? (widget.showLoadingIndicator
            ? () async {
                if (loading) {
                  return;
                }
                safeSetState(() => loading = true);
                try {
                  await widget.onPressed!();
                } finally {
                  if (mounted) {
                    safeSetState(() => loading = false);
                  }
                }
              }
            : () => widget.onPressed!())
        : null;

    final ButtonStyle style = ButtonStyle(
      shape: WidgetStateProperty.resolveWith<OutlinedBorder>((states) {
        if (states.contains(WidgetState.hovered) &&
            widget.options.hoverBorderSide != null) {
          return RoundedRectangleBorder(
            borderRadius:
                widget.options.borderRadius ?? BorderRadius.circular(8),
            side: widget.options.hoverBorderSide!,
          );
        }
        return RoundedRectangleBorder(
          borderRadius: widget.options.borderRadius ?? BorderRadius.circular(8),
          side: widget.options.borderSide ?? BorderSide.none,
        );
      }),
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled) &&
            widget.options.disabledColor != null) {
          return widget.options.disabledColor;
        }
        if (states.contains(WidgetState.hovered) &&
            widget.options.hoverColor != null) {
          return widget.options.hoverColor;
        }
        return widget.options.color;
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled) &&
            widget.options.disabledTextColor != null) {
          return widget.options.disabledTextColor;
        }
        if (states.contains(WidgetState.hovered) &&
            widget.options.hoverTextColor != null) {
          return widget.options.hoverTextColor;
        }
        return widget.options.textStyle?.color ?? Colors.white;
      }),
      padding: WidgetStateProperty.all(
        widget.options.padding ??
            const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      ),
    );

    // Build children (Icon + Text)
    Widget content;
    if ((widget.icon != null || widget.iconData != null) && !loading) {
      Widget icon = widget.icon ??
          Icon(
            widget.iconData!,
            size: widget.options.iconSize,
            color: widget.options.iconColor,
          );

      final bool iconAtStart =
          widget.options.iconAlignment != IconAlignment.end;

      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (iconAtStart)
            Padding(
              padding: widget.options.iconPadding ?? EdgeInsets.zero,
              child: icon,
            ),
          if (iconAtStart) const SizedBox(width: 8),
          Flexible(child: textWidget),
          if (!iconAtStart) const SizedBox(width: 8),
          if (!iconAtStart)
            Padding(
              padding: widget.options.iconPadding ?? EdgeInsets.zero,
              child: icon,
            ),
        ],
      );
    } else {
      content = textWidget;
    }

    return SizedBox(
      height: widget.options.height,
      width: widget.options.width,
      child: FilledButton(
        onPressed: onPressed,
        style: style,
        focusNode: _focusNode,
        child: content,
      ),
    );
  }
}

extension _WithoutColorExtension on TextStyle {
  TextStyle withoutColor() => TextStyle(
        inherit: inherit,
        color: null,
        backgroundColor: backgroundColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        textBaseline: textBaseline,
        height: height,
        leadingDistribution: leadingDistribution,
        locale: locale,
        foreground: foreground,
        background: background,
        shadows: shadows,
        fontFeatures: fontFeatures,
        fontVariations: fontVariations,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationStyle: decorationStyle,
        decorationThickness: decorationThickness,
        debugLabel: debugLabel,
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
        // package: _package,
        overflow: overflow,
      );
}

// Slightly hacky method of getting the layout width of the provided text.
double? _getTextWidth(String? text, TextStyle? style, int maxLines) =>
    text != null
        ? (TextPainter(
            text: TextSpan(text: text, style: style),
            textDirection: TextDirection.ltr,
            maxLines: maxLines,
          )..layout())
            .size
            .width
        : null;

class FFFocusIndicator extends StatefulWidget {
  final Widget Function(FocusNode focusNode)? builder;
  final Widget? child;
  final Border? border;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final void Function()? onTap;
  final void Function()? onLongPress;
  final void Function()? onDoubleTap;

  const FFFocusIndicator({
    super.key,
    this.builder,
    this.child,
    this.border,
    this.borderRadius,
    this.padding,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
  }) : assert(
          builder != null || child != null,
          'Either builder or child must be provided',
        );

  @override
  State<FFFocusIndicator> createState() => _FFFocusIndicatorState();
}

class _FFFocusIndicatorState extends State<FFFocusIndicator> {
  late FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasInteractions = widget.onTap != null ||
        widget.onLongPress != null ||
        widget.onDoubleTap != null;

    Widget childWidget;
    if (widget.builder != null) {
      // Builder mode: pass focus node to builder
      childWidget = widget.builder!(_focusNode);
    } else if (hasInteractions) {
      // Child mode with interactions: wrap in InkWell?
      // Fluent UI usually implies GestureDetector or Button behavior.
      // But InkWell is Material.
      // I'll use GestureDetector.
      childWidget = GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onDoubleTap: widget.onDoubleTap,
        child: widget.child!,
      );
    } else {
      childWidget = widget.child!;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: widget.padding,
      decoration: BoxDecoration(
        border: _hasFocus ? widget.border : null,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
      ),
      child: childWidget,
    );
  }
}
