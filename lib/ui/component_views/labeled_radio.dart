import 'package:flutter/material.dart';

/// Provides a labeled widget with a radio button. Custom designed to support
/// the exam component.
class LabeledRadio extends StatelessWidget {
  const LabeledRadio({
    super.key,
    required this.label,
    required this.padding,
    required this.groupValue,
    required this.value,
    required this.onChanged,
    required this.correct,
    required this.visibleResult,
    required this.enabled,
  });

  final String label;
  final EdgeInsets padding;
  final String groupValue;
  final String value;
  final ValueChanged<String> onChanged;
  final bool correct;
  final bool visibleResult;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (value != groupValue) {
          onChanged(value);
        }
      },
      child: Padding(
        padding: padding,
        child: Row(
          children: <Widget>[
            Opacity(
              opacity: visibleResult && value == groupValue ? 1.0 : 0.0,
              child: correct ? const Icon(Icons.check, color: Colors.green) : const Icon(Icons.close, color: Colors.red),
            ),
            Radio<String>(
              groupValue: groupValue,
              value: value,
              onChanged: enabled ?
                  (String? newValue) {
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