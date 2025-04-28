import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback? onCopy;
  final VoidCallback? onSearch;
  final VoidCallback? onTranslate;

  const ActionButtons({
    super.key,
    required this.onCopy,
    required this.onSearch,
    required this.onTranslate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: IconButton(
        onPressed: onCopy,
        icon: const Icon(Icons.copy),
        tooltip: 'Copy',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: IconButton(
        onPressed: onSearch,
        icon: const Icon(Icons.search),
        tooltip: 'Search',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: IconButton(
        onPressed: onTranslate,
        icon: const Icon(Icons.translate),
        tooltip: 'Translate',
          ),
        ),
      ],
    );
  }
}
