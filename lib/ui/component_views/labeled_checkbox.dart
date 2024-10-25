import 'package:flutter/material.dart';

/// Provides a labeled widget with a radio button. Custom designed to support
/// the exam component.
class LabeledCheckbox extends StatefulWidget {
  const LabeledCheckbox({
    super.key,
    required this.label,
    required this.padding,
    required this.checked,
    required this.onChanged,
    required this.correct,
    required this.visibleResult,
    required this.enabled,
    required this.emphasized,
  });

  final String label;
  final EdgeInsets padding;
  final bool checked;
  final ValueChanged<bool> onChanged;
  final bool correct;
  final bool visibleResult;
  final bool enabled;
  final bool emphasized;

  @override
  State<LabeledCheckbox> createState() => _LabeledCheckboxState();
}

class _LabeledCheckboxState extends State<LabeledCheckbox> {

  bool value = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => flip(!value),
      child: Container(
        color: Colors.red.withOpacity(widget.emphasized ? 0.03 : 0.0),
        padding: widget.padding,
        child: Row(
          children: <Widget>[
            Opacity(
              opacity: widget.visibleResult ? 1.0 : 0.0,
              child: widget.checked ? widget.correct ? const Icon(Icons.check, color: Colors.green) : const Icon(Icons.close, color: Colors.red) : const Icon(Icons.question_mark, color: Colors.black26),
            ),
            IgnorePointer(
              child: Checkbox(value: value, onChanged: (_) {}),
            ),
            Expanded(child: Text(widget.label, style: Theme.of(context).textTheme.bodySmall)),
          ],
        ),
      )
    );
  }

  void flip(bool newValue) {
    if(widget.enabled) {
      value = !value;
      widget.onChanged(newValue);
    }
  }
}