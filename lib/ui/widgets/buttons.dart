import 'package:flutter/material.dart';

///Constructs a button that has an icon.
OutlinedButton createButtonWithIcon(final String label, final Icon icon, final VoidCallback? onPressed, {required key}) {
  return OutlinedButton(
    key: key,
    onPressed: onPressed,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        const SizedBox(width: 5),
        icon,
      ],
    ),
  );
}

///Constructs a button without an icon.
OutlinedButton createButtonWithoutIcon(final String label, final VoidCallback onPressed, {required key}) {
  return OutlinedButton(
    key: key,
    onPressed: onPressed,
    child: Text(label)
  );
}