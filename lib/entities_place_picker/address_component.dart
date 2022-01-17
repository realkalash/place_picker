class AddressComponent {
  String name;
  String shortName;

  AddressComponent({this.name, this.shortName});

  static AddressComponent fromJson(Map json) {
    return AddressComponent(
      name: json['long_name'] as String,
      shortName: json['short_name'] as String,
    );
  }
}
