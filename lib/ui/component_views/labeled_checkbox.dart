import 'package:flutter/material.dart';

/// Provides a labeled widget with a radio button. Custom designed to support
/// the exam component.
class LabeledCheckbox extends StatelessWidget {
  const LabeledCheckbox({
    super.key,
    required this.label,
    required this.padding,
    required this.checked,
    required this.onChanged,
    required this.correct,
    required this.visibleResult,
    required this.enabled,
  });

  final String label;
  final EdgeInsets padding;
  final bool checked;
  final ValueChanged<bool> onChanged;
  final bool correct;
  final bool visibleResult;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(checked),
      child: Padding(
        padding: padding,
        child: Row(
          children: <Widget>[
            Opacity(
              opacity: visibleResult ? 1.0 : 0.0,
              child: checked ? correct ? const Icon(Icons.check, color: Colors.green) : const Icon(Icons.close, color: Colors.red) : const Icon(Icons.question_mark, color: Colors.black26),
            ),
            Checkbox(
              value: checked,
              onChanged: enabled ?
                  (bool? newValue) {
                    onChanged(newValue!);
                  }
                :
                  null,
            ),
            Expanded(child: Text(label)),
          ],
        ),
      ),
    );
  }
}