import 'package:flutter/material.dart';

class FlutterFlowIconButton extends StatefulWidget {
  const FlutterFlowIconButton({
    super.key,
    this.borderColor,
    this.borderRadius,
    this.borderWidth,
    this.buttonSize,
    this.fillColor,
    this.icon,
    this.onPressed,
    this.showLoadingIndicator = false,
    this.value,
  });

  final double? borderRadius;
  final double? buttonSize;
  final Color? fillColor;
  final Color? borderColor;
  final double? borderWidth;
  final Widget? icon;
  final Function()? onPressed;
  final bool showLoadingIndicator;
  final String? value;

  @override
  State<FlutterFlowIconButton> createState() => _FlutterFlowIconButtonState();
}

class _FlutterFlowIconButtonState extends State<FlutterFlowIconButton> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = widget.icon!;

    if (loading) {
      iconWidget = SizedBox(
        width: widget.buttonSize,
        height: widget.buttonSize,
        child: Center(
          child: SizedBox(
            width: (widget.buttonSize ?? 40) * 0.5,
            height: (widget.buttonSize ?? 40) * 0.5,
            child: CircularProgressIndicator(
              color: widget.borderColor,
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    return Container(
      width: widget.buttonSize,
      height: widget.buttonSize,
      decoration: BoxDecoration(
        color: widget.fillColor,
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
        border: Border.all(
          color: widget.borderColor ?? Colors.transparent,
          width: widget.borderWidth ?? 0,
        ),
      ),
      child: IconButton(
        icon: iconWidget,
        onPressed: widget.onPressed == null
            ? null
            : () async {
                if (loading) {
                  return;
                }
                if (widget.showLoadingIndicator) {
                  setState(() {
                    loading = true;
                  });
                }
                try {
                  await widget.onPressed!();
                } finally {
                  if (mounted && widget.showLoadingIndicator) {
                    setState(() {
                      loading = false;
                    });
                  }
                }
              },
        splashRadius: widget.buttonSize,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
