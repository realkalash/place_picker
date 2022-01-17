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
  });
}
