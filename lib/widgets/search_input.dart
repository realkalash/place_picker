import 'dart:async';

import 'package:flutter/material.dart';
//ignore_for_file:cascade_invocations

/// Custom Search input field, showing the search and clear icons.
class SearchInput extends StatefulWidget {
  final ValueChanged<String> onSearchInput;
  final String initString;
  final String hint;
  final TextStyle searchTextStyle;
  final String topText;
  final TextStyle topTextStyle;
  SearchInput({
    Key key,
    @required this.onSearchInput,
    @required this.hint,
    this.initString = '',
    this.searchTextStyle,
    this.topText,
    this.topTextStyle,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => SearchInputState();
}

class SearchInputState extends State<SearchInput> {
  TextEditingController editController = TextEditingController();

  Timer debouncer;

  bool hasSearchEntry = false;

  SearchInputState();

  @override
  void initState() {
    super.initState();
    editController.text = widget.initString;
    editController.addListener(onSearchInputChange);
  }

  @override
  void dispose() {
    editController.removeListener(onSearchInputChange);
    editController.dispose();

    super.dispose();
  }

  void onSearchInputChange() {
    if (editController.text.isEmpty) {
      debouncer?.cancel();
      widget.onSearchInput(editController.text);
      return;
    }

    if (debouncer?.isActive ?? false) {
      debouncer.cancel();
    }

    debouncer = Timer(const Duration(milliseconds: 1000), () {
      widget.onSearchInput(editController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.topText != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                Center(child: Text(widget.topText, style: widget.topTextStyle)),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: <Widget>[
              Icon(Icons.search,
                  color: Theme.of(context).textTheme.bodyText1?.color),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                      hintText: widget.hint, border: InputBorder.none),
                  controller: editController,
                  style: widget.searchTextStyle,
                  onChanged: (value) {
                    setState(() {
                      hasSearchEntry = value.isNotEmpty;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              if (hasSearchEntry)
                GestureDetector(
                  child: const Icon(Icons.clear),
                  onTap: () {
                    editController.clear();
                    setState(() {
                      hasSearchEntry = false;
                    });
                  },
                ),
            ],
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).canvasColor,
          ),
        ),
      ],
    );
  }
}
