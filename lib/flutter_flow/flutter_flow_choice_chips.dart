import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'form_field_controller.dart';

class ChipData {
  const ChipData(this.label, [this.iconData]);
  final String label;
  final IconData? iconData;
}

class ChipStyle {
  const ChipStyle({
    required this.backgroundColor,
    required this.textStyle,
    required this.iconColor,
    required this.iconSize,
    this.labelPadding,
    this.elevation,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
  });

  final Color backgroundColor;
  final TextStyle textStyle;
  final Color iconColor;
  final double iconSize;
  final EdgeInsetsGeometry? labelPadding;
  final double? elevation;
  final Color? borderColor;
  final double? borderWidth;
  final BorderRadius? borderRadius;
}

class FlutterFlowChoiceChips extends StatefulWidget {
  const FlutterFlowChoiceChips({
    super.key,
    required this.options,
    required this.onChanged,
    required this.controller,
    required this.selectedChipStyle,
    required this.unselectedChipStyle,
    required this.chipSpacing,
    this.rowSpacing,
    required this.multiselect,
    this.initialized = true,
    this.alignment = WrapAlignment.start,
    this.wrapped = true,
  });

  final List<ChipData> options;
  final void Function(List<String>?) onChanged;
  final FormFieldController<List<String>> controller;
  final ChipStyle selectedChipStyle;
  final ChipStyle unselectedChipStyle;
  final double chipSpacing;
  final double? rowSpacing;
  final bool multiselect;
  final bool initialized;
  final WrapAlignment alignment;
  final bool wrapped;

  @override
  State<FlutterFlowChoiceChips> createState() => _FlutterFlowChoiceChipsState();
}

class _FlutterFlowChoiceChipsState extends State<FlutterFlowChoiceChips> {
  late List<String> choiceChipValues;
  late List<String> selectedValues;

  @override
  void initState() {
    super.initState();
    choiceChipValues = widget.options.map((option) => option.label).toList();
    selectedValues = widget.controller.value ?? [];
    if (!widget.initialized && selectedValues.isNotEmpty) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (widget.controller.value != null) {
          widget.onChanged(widget.controller.value);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chips = widget.options.map((option) {
      final selected = selectedValues.contains(option.label);
      final style =
          selected ? widget.selectedChipStyle : widget.unselectedChipStyle;

      return ChoiceChip(
        label: Text(
          option.label,
          style: style.textStyle,
        ),
        labelPadding: style.labelPadding,
        avatar: option.iconData != null
            ? Icon(
                option.iconData,
                size: style.iconSize,
                color: style.iconColor,
              )
            : null,
        selected: selected,
        onSelected: (isSelected) {
          if (isSelected) {
            widget.multiselect
                ? selectedValues.add(option.label)
                : selectedValues = [option.label];
          } else {
            if (widget.multiselect) {
              selectedValues.remove(option.label);
            } else {
              // Don't modify if strictly one must be selected?
              // Usually choice chips allow deselecting in multiselect,
              // or switching in single select.
              // If single select and clicking same, maybe allow deselect?
              // Flutter ChoiceChip behavior on single select deselects if we set selected false.
              // But here we are managing state.
              // Assuming standard FF behavior:
              // Single select: always one selected? Or nullable?
              // The controller type is List<String>, so it can be empty.
              selectedValues.remove(option.label);
            }
          }

          setState(() {}); // Update local state

          widget.controller.value = List.from(selectedValues);
          widget.onChanged(selectedValues);
        },
        selectedColor: widget.selectedChipStyle.backgroundColor,
        backgroundColor: widget.unselectedChipStyle.backgroundColor,
        elevation: style.elevation,
        side: style.borderColor != null
            ? BorderSide(
                color: style.borderColor!,
                width: style.borderWidth ?? 1.0,
              )
            : null,
        shape: style.borderRadius != null
            ? RoundedRectangleBorder(borderRadius: style.borderRadius!)
            : null,
      );
    }).toList();

    return widget.wrapped
        ? Wrap(
            spacing: widget.chipSpacing,
            runSpacing: widget.rowSpacing ?? widget.chipSpacing,
            alignment: widget.alignment,
            children: chips,
          )
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: [
                for (var i = 0; i < chips.length; i++) ...[
                  chips[i],
                  if (i < chips.length - 1) SizedBox(width: widget.chipSpacing),
                ],
              ],
            ),
          );
  }
}
