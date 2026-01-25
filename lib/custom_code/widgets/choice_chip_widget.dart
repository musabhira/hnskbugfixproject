// Automatic FlutterFlow imports
import 'package:pocket_mates_app/flutter_flow/form_field_controller.dart';
import 'package:pocket_mates_app/flutter_flow/flutter_flow_widgets.dart';

import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'index.dart'; // Imports other custom widgets

class CustomChoiceChips extends StatefulWidget {
  final List<String> options;
  final String? initialValue;
  final ValueChanged<String?> onChanged;
  final double width;
  final double height;
  final bool allowAddCategory;
  final ValueChanged<String>? onCategoryAdded;

  const CustomChoiceChips({
    required this.width,
    required this.height,
    super.key,
    required this.options,
    this.initialValue,
    required this.onChanged,
    this.allowAddCategory = true,
    this.onCategoryAdded,
  });

  @override
  State<CustomChoiceChips> createState() => _CustomChoiceChipsState();
}

class _CustomChoiceChipsState extends State<CustomChoiceChips> {
  final TextEditingController _textController = TextEditingController();
  late List<String> _currentOptions;

  @override
  void initState() {
    super.initState();
    _currentOptions = List.from(widget.options);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _addCategory() {
    final newCategory = _textController.text.trim();
    if (newCategory.isNotEmpty && !_currentOptions.contains(newCategory)) {
      setState(() {
        _currentOptions.add(newCategory);
        _textController.clear();
      });

      // Notify parent about the new category
      widget.onCategoryAdded?.call(newCategory);

      // Optionally select the newly added category
      widget.onChanged(newCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Choice Chips
        FlutterFlowChoiceChips(
          options: _currentOptions.map((option) => ChipData(option)).toList(),
          onChanged: (val) => widget.onChanged(val?.firstOrNull),
          selectedChipStyle: ChipStyle(
            backgroundColor: FlutterFlowTheme.of(context).accent2,
            textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Montserrat',
                  color: FlutterFlowTheme.of(context).primaryText,
                  letterSpacing: 0.0,
                ),
            iconColor: FlutterFlowTheme.of(context).primaryText,
            iconSize: 18.0,
            elevation: 0.0,
            borderColor: FlutterFlowTheme.of(context).secondary,
            borderWidth: 2.0,
            borderRadius: BorderRadius.circular(8.0),
          ),
          unselectedChipStyle: ChipStyle(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Montserrat',
                  color: FlutterFlowTheme.of(context).secondaryText,
                  letterSpacing: 0.0,
                ),
            iconColor: FlutterFlowTheme.of(context).secondaryText,
            iconSize: 18.0,
            elevation: 0.0,
            borderColor: FlutterFlowTheme.of(context).alternate,
            borderWidth: 2.0,
            borderRadius: BorderRadius.circular(8.0),
          ),
          chipSpacing: 8.0,
          rowSpacing: 8.0,
          multiselect: false,
          initialized: widget.initialValue != null,
          alignment: WrapAlignment.start,
          controller: FormFieldController<List<String>>(
            widget.initialValue != null ? [widget.initialValue!] : [],
          ),
          wrapped: true,
        ),

        // Add Category Section
        if (widget.allowAddCategory) ...[
          const SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: 'Add new category...',
                    hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Montserrat',
                          color: FlutterFlowTheme.of(context).secondaryText,
                          letterSpacing: 0.0,
                        ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: FlutterFlowTheme.of(context).alternate,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: FlutterFlowTheme.of(context).secondary,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: const EdgeInsetsDirectional.fromSTEB(
                        12.0, 0.0, 0.0, 0.0),
                  ),
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Montserrat',
                        letterSpacing: 0.0,
                      ),
                  onFieldSubmitted: (_) => _addCategory(),
                ),
              ),
              const SizedBox(width: 8.0),
              ElevatedButton(
                onPressed: _addCategory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: FlutterFlowTheme.of(context).primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                ),
                child: const Text('Add'),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
