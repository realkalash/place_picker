class LocalizationItem {
  final String languageCode;
  final String nearBy;
  final String findingPlace;
  final String noResultsFound;
  final String unnamedLocation;
  final String tapToSelectLocation;

  final String approximatePointInGmaps;
  final String tipBottomText;
  final String choosedPlaceText;
  final String search;

  final String youCantChooseThisState;

  final String submit;

  final FormLocalizationItem formLocalizationItem;

  const LocalizationItem({
    this.languageCode = 'en_us',
    this.nearBy = 'Nearby Places',
    this.findingPlace = 'Finding place...',
    this.noResultsFound = 'No results found',
    this.unnamedLocation = 'Unnamed location',
    this.tapToSelectLocation = 'Tap to select this location',
    this.approximatePointInGmaps = 'Approximate point in Google maps',
    this.tipBottomText = 'Tap to choose address',
    this.choosedPlaceText = 'Choosed place',
    this.search = 'Search...',
    this.youCantChooseThisState = 'You can\'t choose other states except ',
    this.submit = 'Submit',
    this.formLocalizationItem = const FormLocalizationItem(),
  });
}

class FormLocalizationItem {
  final String formattedAddress;
  final String city;
  final String streetNumber;
  final String country;

  /// For example state or region
  final String administrativeAreaLevel1;
  final String street;

  const FormLocalizationItem({
    this.formattedAddress = 'formattedAddress',
    this.country = 'Country',
    this.administrativeAreaLevel1 = 'Region',
    this.city = 'City',
    this.street = 'Street',
    this.streetNumber = 'Street number',
  });
}
