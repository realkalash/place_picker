/// Autocomplete results item returned from Google will be deserialized
/// into this model.
class AutoCompleteItem {
  /// The id of the place. This helps to fetch the lat,lng of the place.
  String id;

  /// The text (name of place) displayed in the autocomplete suggestions list.
  String text;

  /// Assistive index to begin highlight of matched part of the [text] with
  /// the original query
  int offset;

  /// Length of matched part of the [text]
  int length;

  AutoCompleteItem({
    this.id = 'null',
    required this.text,
    required this.offset,
    required this.length,
  });
}
