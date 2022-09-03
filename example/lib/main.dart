import 'package:flutter/material.dart';
import 'package:place_picker/entities_place_picker/entities.dart';
import 'package:place_picker/place_picker.dart';
import 'package:place_picker/widgets/form_field_page.dart';

void main() {
  runApp(MaterialApp(
    title: 'Example app',
    home: FirstPage(),
  ));
}

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  String? choosedLocation;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: Column(
          children: [
            Text('Running on: Flutter'),
            Text('Choosed location: $choosedLocation'),
            ElevatedButton(
              onPressed: () {
                _openChooseLocationOSMPage();
              },
              child: Text('Choose location OSM'),
            ),
            ElevatedButton(
              onPressed: () {
                _openChooseLocationGooglePage();
              },
              child: Text('Choose location Google'),
            ),
            ElevatedButton(
              onPressed: () {
                _openChooseLocationFormFieldPage();
              },
              child: Text('Choose location FormField'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openChooseLocationOSMPage() async {
    final result = await Navigator.of(context).push<LocationResult?>(
      MaterialPageRoute(
        builder: (c) => PlacePicker(
          apiKey: 'apiKey',
          showChoosedPlaceCoordinates: true,
          bottomWidget:
              Container(child: Text('bottom widget'), color: Colors.red),
          geocoderProvider: GeocoderProvider.google,
          isNeedToUseGeocoding: false,
          mapProvider: MapProvider.osm, // MapProvider.google
          searchTopText: 'Only one line height tip',
          showArrow: true,
          userAgentPackageName: 'com.example.app',
          initialZoom: 16.0,
          showTip: true,
          initialLocation: PlaceLatLng(49.442436740142384, 26.99113044049725),
          isNeedToShowLocationName: false,
          localizationItem: LocalizationItem(
            languageCode: 'en_us',
            search: 'Search',
            tipBottomText: 'Пiдказка знизу',
          ),
        ),
      ),
    );

    if (result != null) {
      setState(() {
        choosedLocation = result.toStringWithNewLine();
      });
    }
  }

  Future<void> _openChooseLocationGooglePage() async {
    final result = await Navigator.of(context).push<LocationResult?>(
      MaterialPageRoute(
        builder: (c) => PlacePicker(
          apiKey: 'apiKey',
          showChoosedPlaceCoordinates: true,
          bottomWidget:
              Container(child: Text('bottom widget'), color: Colors.red),
          geocoderProvider: GeocoderProvider.google,
          isNeedToUseGeocoding: false,
          mapProvider: MapProvider.osm, // MapProvider.google
          searchTopText: 'Only one line height tip',
          showArrow: true,
          initialZoom: 16.0,
          showTip: true,
          initialLocation: PlaceLatLng(49.442436740142384, 26.99113044049725),
          isNeedToShowLocationName: false,
          localizationItem: LocalizationItem(
            languageCode: 'en_us',
            search: 'Search',
            tipBottomText: 'Пiдказка знизу',
          ),
        ),
      ),
    );

    if (result != null) {
      setState(() {
        choosedLocation = result.toStringWithNewLine();
      });
    }
  }

  Future<void> _openChooseLocationFormFieldPage() async {
    final result = await Navigator.of(context).push<LocationResult?>(
      MaterialPageRoute(
        builder: (c) => PlacePicker(
          apiKey: 'apiKey',
          citySuggestions: _fetchCities,
          streetNumberSuggestions: _fetchStreetNumbers,
          bottomWidget:
              Container(child: Text('bottom widget'), color: Colors.red),
          mapProvider: MapProvider.formField, // MapProvider.google
          searchTopText: 'Only one line height tip',
          showArrow: true,
          showTip: true,
          formFieldParams: FormFieldParams(
            showFormattedAddressField: false,
          ),
          localizationItem: LocalizationItem(
            languageCode: 'en_us',
            search: 'Search',
            tipBottomText: 'Пiдказка знизу',
            submit: 'Submit button',
            formLocalizationItem: FormLocalizationItem(
              city: 'City label',
              administrativeAreaLevel1: 'Region',
            ),
          ),
        ),
      ),
    );

    if (result != null) {
      setState(() {
        choosedLocation = result.toStringWithNewLine();
      });
    }
  }

  Future<List<String>> _fetchCities(String query) async {
    await Future.delayed(Duration(milliseconds: 200));
    final _suggestions = [
      'City 1',
      'City 2',
      'City 3',
      'City 4',
      'City 5',
      'City 6'
    ];
    List<String> _filteredSuggestions = _suggestions.where((element) {
      return element.toLowerCase().contains(query.toLowerCase());
    }).toList();
    return _filteredSuggestions;
  }

  Future<List<String>> _fetchStreetNumbers(String query) async {
    await Future.delayed(Duration(milliseconds: 200));
    final _suggestions = List.generate(150, (index) => index.toString());
    List<String> _filteredSuggestions = _suggestions.where((element) {
      return element.toLowerCase().contains(query.toLowerCase());
    }).toList();
    return _filteredSuggestions;
  }
}
