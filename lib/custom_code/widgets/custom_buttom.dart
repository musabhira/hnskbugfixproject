// Automatic FlutterFlow imports
import 'package:pocket_mates_app/flutter_flow/flutter_flow_widgets.dart';

import '/flutter_flow/flutter_flow_theme.dart';
// Imports other custom widgets
// Imports custom actions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

class CustomButton extends StatelessWidget {
  final String textKey;
  final Widget? routeWidget;
  final Color buttonColor;
  final Color textColor;
  final double width;
  final double height;

  const CustomButton({
    required this.width,
    required this.height,
    super.key,
    required this.textKey,
    this.routeWidget,
    required this.buttonColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 3.0, 0.0),
        child: FFButtonWidget(
          onPressed: routeWidget != null
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => routeWidget!),
                  );
                }
              : () {
                  print('Button pressed ...');
                },
          text: textKey,
          options: FFButtonOptions(
            height: 40.0,
            padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
            iconPadding:
                const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
            color: buttonColor,
            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                  fontFamily: 'Poppins',
                  color: textColor,
                  letterSpacing: 0.0,
                ),
            elevation: 0.0,
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }
}
