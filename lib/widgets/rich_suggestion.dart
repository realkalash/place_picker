import 'package:flutter/material.dart';

import 'package:place_picker/entities_place_picker/entities.dart';

class RichSuggestion extends StatelessWidget {
  final VoidCallback? onTap;
  final AutoCompleteItem autoCompleteItem;

  RichSuggestion({
    Key? key,
    this.onTap,
    required this.autoCompleteItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: RichText(text: TextSpan(children: getStyledTexts(context))),
        ),
        onTap: onTap,
      ),
    );
  }

  List<TextSpan> getStyledTexts(BuildContext context) {
    final result = <TextSpan>[];
    final style = const TextStyle(color: Colors.grey, fontSize: 15);

    final startText =
        autoCompleteItem.text.substring(0, autoCompleteItem.offset);
    if ((startText).isNotEmpty) {
      result.add(TextSpan(text: startText, style: style));
    }

    final boldText = autoCompleteItem.text.substring(autoCompleteItem.offset,
        autoCompleteItem.offset + autoCompleteItem.length);
    result.add(
      TextSpan(
          text: boldText,
          style: style.copyWith(
              color: Theme.of(context).textTheme.bodyText1?.color)),
    );

    final remainingText = autoCompleteItem.text
        .substring(autoCompleteItem.offset + autoCompleteItem.length);
    result.add(TextSpan(text: remainingText, style: style));

    return result;
  }
}
