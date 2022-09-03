import 'package:flutter/material.dart';
import 'package:place_picker/entities_place_picker/entities.dart';
import 'package:place_picker/place_picker.dart';

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
            TextButton(
              onPressed: () {
                _openChooseLocationPage();
              },
              child: Text('Choose location'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openChooseLocationPage() async {
    final result = await Navigator.of(context).push<LocationResult?>(
      MaterialPageRoute(
        builder: (c) => PlacePicker(
          apiKey: 'apiKey',
          showChoosedPlaceCoordinates: true,
          bottomWidget:
              Container(child: Text('bottom widget'), color: Colors.red),
          geocoderProvider: GeocoderProvider.google,
          isNeedToUseGeocoding: false,
          mapProvider: MapProvider.google, // MapProvider.google
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
      choosedLocation = result.toString();
    }
  }
}
