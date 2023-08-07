import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart' as osm;
import 'package:google_maps_flutter/google_maps_flutter.dart' as google;
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as latlong;
import 'package:location/location.dart';
import 'package:place_picker/widgets/form_field_page.dart';
import 'package:uuid/uuid.dart';

import 'package:place_picker/entities_place_picker/entities.dart';
import 'package:place_picker/widgets/widgets.dart';
import 'package:yandex_geocoder/yandex_geocoder.dart';
import 'extensions.dart';

enum MapProvider {
  google,
  osm,
  formField,
}

enum GeocoderProvider {
  google,
  yandex,
}

/// Place picker widget made with map widget from
/// [google_maps_flutter](https://github.com/flutter/plugins/tree/master/packages/google_maps_flutter)
/// and other API calls to [Google Places API](https://developers.google.com/places/web-service/intro)
///
/// * If you use [MapProvider.google]
///
/// API key provided should have `Maps SDK for Android`, `Maps SDK for iOS`
/// and `Places API`  enabled for it.
///
/// * If you use [MapProvider.osm]
///
/// You should specify [userAgentPackageName].
///
/// Example usage:
/// on your page
/// ``` dart
///  TextButton(
///    onPressed: () {
///      Navigator.of(context).push<LocationResult?>(
///        MaterialPageRoute(
///          builder: (c) => PlacePicker(
///            apiKey: 'apiKey',
///            mapProvider: MapProvider.osm, // MapProvider.google
///            userAgentPackageName: 'com.example.app',
///        ),
///      );
///    },
///    child: Text('Choose location'),
///  )
/// ```
class PlacePicker extends StatefulWidget {
  /// API key generated from Google Cloud Console. You can get an API key
  /// [here](https://cloud.google.com/maps-platform/)
  final String apiKey;

  /// Location to be displayed when screen is showed. If this is set or not null, the
  /// map does not pan to the user's current location.
  final PlaceLatLng? initialLocation;

  /// Can be different for different providers
  final double initialZoom;

  /// First text that will be autofilled in search field
  final String initString;
  final bool showChoosedPlaceCoordinates;
  final bool showArrow;
  final Widget? bottomWidget;
  final Widget? navigationIconWidget;
  final LocalizationItem localizationItem;

  /// It can only be single line height
  final String? searchTopText;
  final TextStyle? searchTopTextStyle;

  /// Bottom container with text tip
  final bool showTip;

  /// Color of bottom tip
  final Color? colorTip;

  /// If `true` map after selecting place after tap on search item will use additinal request
  /// to geocode location
  final bool isNeedToUseGeocoding;

  /// If `true` the map will try to show location name. If no name provided or error throwed
  /// shows `unnamedLocation` text from [LocalizationItem]
  final bool isNeedToShowLocationName;

  /// If not `null` user can't choose other state exept [userCanOnlyPickState]
  final String? userCanOnlyPickState;

  /// See inner doc
  final MapProvider mapProvider;

  /// Used to geocode location name
  final GeocoderProvider geocoderProvider;

  /// Used for OSM maps. E.x com.example.app
  final String userAgentPackageName;

  /// Use this only with [mapProvider] [MapProvider.formField]
  final Future<List<String>> Function(String)? formattedAddressSuggestions;

  /// Use this only with [mapProvider] [MapProvider.formField]
  final Future<List<String>> Function(String)? citySuggestions;

  /// Use this only with [mapProvider] [MapProvider.formField]
  final Future<List<String>> Function(String)? streetNumberSuggestions;

  /// Use this only with [mapProvider] [MapProvider.formField]
  final Future<List<String>> Function(String)? streetSuggestions;

  /// Use this only with [mapProvider] [MapProvider.formField]
  final Future<List<String>> Function(String)? countrySuggestions;

  /// Use this only with [mapProvider] [MapProvider.formField]
  final Future<List<String>> Function(String)? administrativeArea1Suggestions;

  /// Use this only with [mapProvider] [MapProvider.formField]
  final FormFieldParams formFieldParams;

  /// Place picker widget made with map widget from
  /// [google_maps_flutter](https://github.com/flutter/plugins/tree/master/packages/google_maps_flutter)
  /// and other API calls to [Google Places API](https://developers.google.com/places/web-service/intro)
  ///
  /// API key provided should have `Maps SDK for Android`, `Maps SDK for iOS`
  /// and `Places API`  enabled for it.
  ///
  /// returns [LocationResult] on pop route.
  PlacePicker({
    Key? key,
    this.initialLocation,
    this.initialZoom = 17.0,
    this.localizationItem = const LocalizationItem(),
    this.initString = '',
    this.showChoosedPlaceCoordinates = true,
    this.isNeedToShowLocationName = true,
    this.showArrow = true,
    this.bottomWidget,
    required this.apiKey,
    this.searchTopText,
    this.searchTopTextStyle,
    this.showTip = true,
    this.navigationIconWidget,
    this.isNeedToUseGeocoding = true,
    this.userCanOnlyPickState,
    this.colorTip,
    this.mapProvider = MapProvider.google,
    this.geocoderProvider = GeocoderProvider.google,
    this.userAgentPackageName = 'com.example.app',
    this.formattedAddressSuggestions,
    this.citySuggestions,
    this.streetNumberSuggestions,
    this.countrySuggestions,
    this.administrativeArea1Suggestions,
    this.streetSuggestions,
    this.formFieldParams = const FormFieldParams(),
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => PlacePickerState(localizationItem);
}

/// Place picker state
class PlacePickerState extends State<PlacePicker> {
  google.GoogleMapController? googleMapController;
  osm.MapController? osmMapController;

  /// Indicator for the selected location
  final Set<PlaceMarker> markers = {};

  /// Result returned after user completes selection
  LocationResult? locationResult;

  /// Overlay to display autocomplete suggestions
  OverlayEntry? overlayEntry;

  List<NearbyPlace> nearbyPlaces = [];

  /// Session token required for autocomplete API call
  String sessionToken = Uuid().v4();

  GlobalKey appBarKey = GlobalKey();

  /// indicate `true` when user request search
  bool hasSearchTerm = false;

  String previousSearchTerm = '';

  LocalizationItem _localizationItem;

  // constructor
  PlacePickerState(this._localizationItem);

  void onMapCreated(google.GoogleMapController controller) {
    googleMapController = controller;
    moveToCurrentUserLocation();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.mapProvider == MapProvider.osm) {
      osmMapController = osm.MapController();
    }
    _localizationItem = widget.localizationItem;
  }

  @override
  void dispose() {
    overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mapProvider == MapProvider.formField) {
      return FormWidget(
        initString: widget.initString,
        showArrow: widget.showArrow,
        localizationItem: widget.localizationItem,
        showTip: widget.showTip,
        tipText: widget.localizationItem.tipBottomText,
        formFieldParams: widget.formFieldParams,
        administrativeArea1Suggestions: widget.administrativeArea1Suggestions,
        bottomWidget: widget.bottomWidget,
        citySuggestions: widget.citySuggestions,
        colorTip: widget.colorTip,
        countrySuggestions: widget.countrySuggestions,
        formattedAddressSuggestions: widget.formattedAddressSuggestions,
        searchTopText: widget.searchTopText,
        searchTopTextStyle: widget.searchTopTextStyle,
        streetNumberSuggestions: widget.streetNumberSuggestions,
        streetSuggestions: widget.streetSuggestions,
      );
    }
    return Scaffold(
      appBar: AppBar(
        key: appBarKey,
        toolbarHeight: widget.searchTopText == null ? null : 120,
        title: SearchInput(
          onSearchInput: searchPlace,
          initString: widget.initString,
          hint: widget.localizationItem.search,
          topText: widget.searchTopText,
          topTextStyle: widget.searchTopTextStyle,
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: buildMap(),
          ),
          // if (this.hasSearchTerm)
          SelectPlaceAction(
            locationName: getLocationName(),
            onTap: () {
              if (widget.userCanOnlyPickState != null) {
                if (locationResult?.administrativeAreaLevel1?.shortName ==
                    widget.userCanOnlyPickState) {
                  Navigator.of(context).pop<LocationResult>(locationResult);
                }
              } else {
                Navigator.of(context).pop<LocationResult>(locationResult);
              }
            },
            approximatePointInGmapsText:
                _localizationItem.approximatePointInGmaps,
            choosedPlaceText: _localizationItem.choosedPlaceText,
            showTip: widget.userCanOnlyPickState != null
                ? (locationResult?.administrativeAreaLevel1?.shortName ?? '') !=
                        widget.userCanOnlyPickState
                    ? true
                    : widget.showTip
                : widget.showTip,
            tipText: widget.userCanOnlyPickState != null
                ? _localizationItem.youCantChooseThisState
                : _localizationItem.tipBottomText,
            latLngString:
                '${locationResult?.latLng?.latitude.toStringAsFixed(7)}, ${locationResult?.latLng?.longitude.toStringAsFixed(7)}',
            showChoosedPlaceCoordinates: widget.showChoosedPlaceCoordinates,
            showArrow: widget.showArrow,
            bottomWidget: widget.bottomWidget,
            iconWidget: widget.navigationIconWidget,
            colorTip: widget.colorTip,
            showChoosedPlaceName: widget.isNeedToShowLocationName,
          ),
        ],
      ),
    );
  }

  Widget buildMap() {
    if (widget.mapProvider == MapProvider.osm) {
      return osm.FlutterMap(
        mapController: osmMapController,
        children: markers.map((e) => e.toWidget()).toList(),
        // layers: [
        //   osm.TileLayerOptions(
        //     urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
        //     userAgentPackageName: widget.userAgentPackageName,
        //   ),
        //   osm.MarkerLayerOptions(
        //     markers: markers.map((e) => e.toOsmMarker()).toList(),
        //   ),
        // ],
        options: osm.MapOptions(
          onTap: (tapPosition, latLng) {
            clearOverlay();
            setMarker(latLng);
            moveToLocation(
              latLng.toPlaceLatLng(),
              isNeedToGeocode: true,
            );
          },
          center: widget.initialLocation != null
              ? widget.initialLocation!.toOsmLatLng()
              : latlong.LatLng(51.509364, -0.128928),
          zoom: widget.initialZoom,
        ),
      );
    }
    return google.GoogleMap(
      initialCameraPosition: google.CameraPosition(
        target: widget.initialLocation != null
            ? (widget.initialLocation!.toGoogleLatLong())
            : const google.LatLng(5.6037, 0.1870),
        zoom: widget.initialZoom,
      ),
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      onMapCreated: onMapCreated,
      buildingsEnabled: true,
      onTap: (latLng) {
        clearOverlay();
        setMarker(latLng.toOsmLatLong());
        moveToLocation(
          latLng.toPlaceLatLng(),
          isNeedToGeocode: true,
        );
      },
      markers: markers.map((e) => e.toGoogleMarker()).toSet(),
    );
  }

  /// Hides the autocomplete overlay
  void clearOverlay() {
    if (overlayEntry != null) {
      overlayEntry?.remove();
      overlayEntry = null;
    }
  }

  /// Begins the search process by displaying a "wait" overlay then
  /// proceeds to fetch the autocomplete list. The bottom "dialog"
  /// is hidden so as to give more room and better experience for the
  /// autocomplete list overlay.
  void searchPlace(String place) {
    try {
      // on keyboard dismissal, the search was being triggered again
      // this is to cap that.
      if (place == previousSearchTerm) {
        return;
      }

      previousSearchTerm = place;

      clearOverlay();

      setState(() {
        hasSearchTerm = place.isNotEmpty;
      });

      if (place.isEmpty) {
        return;
      }

      final renderBox = context.findRenderObject() as RenderBox;
      final size = renderBox.size;

      final appBarBox =
          appBarKey.currentContext?.findRenderObject() as RenderBox;

      overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: appBarBox.size.height,
          width: size.width,
          child: Material(
            elevation: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Row(
                children: <Widget>[
                  const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Text(
                      _localizationItem.findingPlace,
                      style: const TextStyle(fontSize: 16),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
      if (overlayEntry != null) Overlay.of(context)?.insert(overlayEntry!);

      autoCompleteSearch(place);
    } catch (e) {
      printError('Exception throwed by map package: $e');
    }
  }

  /// Fetches the place autocomplete list with the query [place].
  void autoCompleteSearch(String place) async {
    try {
      place = place.replaceAll(' ', '+');

      var endpoint =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?'
          'key=${widget.apiKey}&'
          'language=${_localizationItem.languageCode}&'
          'input={$place}&sessiontoken=$sessionToken';

      if (locationResult != null) {
        endpoint += '&location=${locationResult?.latLng?.latitude},'
            '${locationResult?.latLng?.longitude}';
      }

      final response = await http.get(Uri.parse(endpoint));

      if (response.statusCode != 200) {
        throw Error();
      }

      final dynamic responseJson = jsonDecode(response.body);
      print('Map recieved: $responseJson');

      if (responseJson['predictions'] == null) {
        throw Error();
      }

      var predictions = responseJson['predictions'] as List<dynamic>;

      var suggestions = <RichSuggestion>[];

      if (predictions.isEmpty) {
        var aci = AutoCompleteItem(
          text: _localizationItem.noResultsFound,
          offset: 0,
          length: 0,
        );

        suggestions.add(RichSuggestion(autoCompleteItem: aci, onTap: () {}));
      } else {
        for (dynamic t in predictions) {
          final aci = AutoCompleteItem(
            id: t['place_id'] as String,
            text: t['description'] as String,
            offset: t['matched_substrings'][0]['offset'] as int,
            length: t['matched_substrings'][0]['length'] as int,
          );

          suggestions.add(RichSuggestion(
              autoCompleteItem: aci,
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
                decodeAndSelectPlace(aci.id);
              }));
        }
      }

      displayAutoCompleteSuggestions(suggestions);
    } catch (e) {
      printError('Exception throwed by map package: $e');
    }
  }

  /// To navigate to the selected place from the autocomplete list to the map,
  /// the lat,lng is required. This method fetches the lat,lng of the place and
  /// proceeds to moving the map to that location.
  void decodeAndSelectPlace(String placeId) async {
    clearOverlay();

    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?key=${widget.apiKey}&'
        'language=${_localizationItem.languageCode}&'
        'placeid=$placeId',
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Error();
      }

      final dynamic responseJson = jsonDecode(response.body);

      if (responseJson['result'] == null) {
        throw Error();
      }
      print('Map recieved: $responseJson');

      final dynamic result = responseJson['result'];
      final dynamic location = result['geometry']['location'];
      final latLng =
          google.LatLng(location['lat'] as double, location['lng'] as double);
      final dynamic addressComponents = result['address_components'];
      moveToLocation(
        latLng.toPlaceLatLng(),
        isNeedToGeocode: false,
      );
      locationResult = const LocationResult();
      if (addressComponents != null) {
        String? name,
            postalCode,
            locality,
            streetNumber,
            formattedAddress,
            placeId;
        AddressComponent? administrativeAreaLevel1,
            administrativeAreaLevel2,
            subLocalityLevel1,
            subLocalityLevel2,
            city,
            country;

        name = result['name'] as String;
        formattedAddress = result['formatted_address'] as String;
        placeId = result['place_id'] as String;
        for (var item in addressComponents as List<dynamic>) {
          final _item = item as Map;
          final itemTypes = _item['types'] as List<dynamic>;

          if (itemTypes.contains('postal_code')) {
            postalCode = _item['long_name'] as String;
          }
          if (itemTypes.contains('administrative_area_level_1')) {
            administrativeAreaLevel1 = AddressComponent.fromJson(_item);
          }
          if (itemTypes.contains('administrative_area_level_2')) {
            administrativeAreaLevel2 = AddressComponent.fromJson(_item);
          }
          if (itemTypes.contains('locality')) {
            city = AddressComponent.fromJson(_item);
            locality = city.name;
          }
          if (itemTypes.contains('street_number')) {
            streetNumber = _item['long_name'] as String;
          }
          if (itemTypes.contains('country')) {
            country = AddressComponent.fromJson(_item);
          }
          if (itemTypes.contains('sublocality_level_1')) {
            subLocalityLevel1 = AddressComponent.fromJson(_item);
          }
          if (itemTypes.contains('sublocality_level_2')) {
            subLocalityLevel2 = AddressComponent.fromJson(_item);
          }
        }
        locationResult = locationResult?.copyWith(
          administrativeAreaLevel1: administrativeAreaLevel1,
          administrativeAreaLevel2: administrativeAreaLevel2,
          city: city,
          country: country,
          formattedAddress: formattedAddress,
          latLng: latLng,
          locality: locality,
          name: name,
          placeId: placeId,
          postalCode: postalCode,
          streetNumber: streetNumber,
          subLocalityLevel1: subLocalityLevel1,
          subLocalityLevel2: subLocalityLevel2,
        );
      }
    } catch (e) {
      printError('Exception throwed by map package [decodeAndSelectPlace]: $e');
    }
  }

  /// Display autocomplete suggestions with the overlay.
  void displayAutoCompleteSuggestions(List<RichSuggestion> suggestions) {
    final renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    final appBarBox = appBarKey.currentContext?.findRenderObject() as RenderBox;

    clearOverlay();

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        top: appBarBox.size.height,
        child: Material(elevation: 1, child: Column(children: suggestions)),
      ),
    );
    if (overlayEntry != null) Overlay.of(context)?.insert(overlayEntry!);
  }

  /// Utility function to get clean readable name of a location. First checks
  /// for a human-readable name from the nearby list. This helps in the cases
  /// that the user selects from the nearby list (and expects to see that as a
  /// result, instead of road name). If no name is found from the nearby list,
  /// then the road name returned is used instead.
  String getLocationName() {
    if (locationResult == null) {
      return _localizationItem.unnamedLocation;
    }

    for (var np in nearbyPlaces) {
      if (np.latLng == locationResult?.latLng &&
          np.name != locationResult?.locality) {
        locationResult?.copyWith(name: np.name);
        return '${np.name}, ${locationResult?.locality}';
      }
    }
    if (locationResult?.name == null || locationResult?.locality == null) {
      if (locationResult?.formattedAddress == null) {
        return _localizationItem.unnamedLocation;
      } else {
        return locationResult!.formattedAddress!;
      }
    }
    return '${locationResult?.name}, ${locationResult?.locality}';
  }

  /// Moves the marker to the indicated lat,lng
  void setMarker(latlong.LatLng latLng) {
    // markers.clear();
    setState(() {
      markers.clear();
      markers.add(
        PlaceMarker(markerId: 'selected-location', position: latLng),
      );
    });
  }

  /// Fetches and updates the nearby places to the provided lat,lng
  void getNearbyPlaces(google.LatLng latLng) async {
    try {
      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json?'
          'key=${widget.apiKey}&location=${latLng.latitude},${latLng.longitude}'
          '&radius=150&language=${_localizationItem.languageCode}');

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Error();
      }

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
      print('Map recieved: $responseJson');

      if (responseJson['results'] == null) {
        throw Error(
          error: responseJson.toString(),
          message: response.reasonPhrase,
          statusCode: response.statusCode,
        );
      }

      nearbyPlaces.clear();
      if (responseJson is List<Map<String, dynamic>>) {
        for (var item
            in responseJson['results'] as List<Map<String, dynamic>>) {
          final nearbyPlace = NearbyPlace(
            name: item['name'] as String,
            icon: item['icon'] as String,
            latLng: google.LatLng(
              item['geometry']['location']['lat'] as double,
              item['geometry']['location']['lng'] as double,
            ),
          );

          nearbyPlaces.add(nearbyPlace);
        }
      }

      // to update the nearby places
      setState(() {
        // this is to require the result to show
        hasSearchTerm = false;
      });
    } catch (e) {
      printError('Exception throwed by map package: $e');
    }
  }

  void reverseGeocodeLatLng(google.LatLng latLng) {
    if (widget.isNeedToUseGeocoding == false &&
        widget.showChoosedPlaceCoordinates) {
      setState(() {
        locationResult = LocationResult(
          latLng: latLng,
        );
      });
      return;
    }
    if (widget.mapProvider == MapProvider.google) {
      reverseGeocodeLatLngGoogle(latLng);
    }
    if (widget.geocoderProvider == GeocoderProvider.yandex) {
      reverseGeocodeLatLngYandex(latLng);
    }
  }

  /// This method gets the human readable name of the location. Mostly appears
  /// to be the road name and the locality.
  void reverseGeocodeLatLngGoogle(google.LatLng latLng) async {
    try {
      final url = Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?'
          'latlng=${latLng.latitude},${latLng.longitude}&'
          'language=${_localizationItem.languageCode}&'
          'key=${widget.apiKey}');

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Error();
      }

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      print('Map recieved: $responseJson');

      if (responseJson['results'] == null) {
        throw Exception(responseJson['error_message'] ?? 'Undefined error');
      }

      final result = responseJson['results'][0] as Map<String, dynamic>;

      setState(() {
        String? name,
            locality,
            postalCode,
            country,
            administrativeAreaLevel1,
            administrativeAreaLevel2,
            city,
            subLocalityLevel1,
            subLocalityLevel2;
        var isOnStreet = false;
        if ((result['address_components'] as List<dynamic>).isNotEmpty) {
          final addressComponents =
              (result['address_components'] as List<dynamic>)
                  .map((dynamic e) => e as Map<String, dynamic>)
                  .toList();
          for (var i = 0; i < addressComponents.length; i++) {
            var tmp = addressComponents[i];
            var types = tmp['types'] as List<dynamic>?;
            var shortName = tmp['short_name'] as String;
            if (types == null) {
              continue;
            }
            if (i == 0) {
              // [street_number]
              name = shortName;
              isOnStreet = types.contains('street_number');
              // other index 0 types
              // [establishment, point_of_interest, subway_station, transit_station]
              // [premise]
              // [route]
            } else if (i == 1 && isOnStreet) {
              if (types.contains('route')) {
                name = '${name ?? ''}${', $shortName'}';
              }
            } else {
              if (types.contains('sublocality_level_1')) {
                subLocalityLevel1 = shortName;
              } else if (types.contains('sublocality_level_2')) {
                subLocalityLevel2 = shortName;
              } else if (types.contains('locality')) {
                locality = shortName;
              } else if (types.contains('administrative_area_level_2')) {
                administrativeAreaLevel2 = shortName;
              } else if (types.contains('administrative_area_level_1')) {
                administrativeAreaLevel1 = shortName;
              } else if (types.contains('country')) {
                country = shortName;
              } else if (types.contains('postal_code')) {
                postalCode = shortName;
              }
            }
          }
        }
        locality = locality ?? administrativeAreaLevel1;
        city = locality;
        locationResult = LocationResult(
          name: name,
          locality: locality,
          latLng: latLng,
          formattedAddress: result['formatted_address'] as String,
          placeId: result['place_id'] as String,
          postalCode: postalCode,
          country: AddressComponent(name: country, shortName: country),
          administrativeAreaLevel1: AddressComponent(
              name: administrativeAreaLevel1,
              shortName: administrativeAreaLevel1),
          administrativeAreaLevel2: AddressComponent(
              name: administrativeAreaLevel2,
              shortName: administrativeAreaLevel2),
          city: AddressComponent(name: city, shortName: city),
          subLocalityLevel1: AddressComponent(
              name: subLocalityLevel1, shortName: subLocalityLevel1),
          subLocalityLevel2: AddressComponent(
              name: subLocalityLevel2, shortName: subLocalityLevel2),
        );
      });
    } catch (e) {
      printError('Exception throwed by map package: $e');
    }
  }

  /// This method gets the human readable name of the location. Mostly appears
  /// to be the road name and the locality.
  void reverseGeocodeLatLngYandex(google.LatLng latLng) async {
    try {
      final YandexGeocoder geocoder = YandexGeocoder(apiKey: widget.apiKey);

      final GeocodeResponse geocodeFromPoint = await geocoder.getGeocode(
        GeocodeRequest(
          geocode: PointGeocode(latitude: 55.771899, longitude: 37.597576),
          lang: Lang.enEn,
        ),
      );

      print('Map recieved: ${geocodeFromPoint.firstFullAddress}');
      final firstAddress = geocodeFromPoint.firstFullAddress;
      setState(() {
        locationResult = LocationResult(
          name: firstAddress.formattedAddress,
          locality: firstAddress.countryCode,
          latLng: latLng,
          formattedAddress: firstAddress.formattedAddress,
          placeId: '',
          postalCode: firstAddress.postalCode,
          country: AddressComponent(
              name: firstAddress.countryCode,
              shortName: firstAddress.countryCode),
          administrativeAreaLevel1: AddressComponent(
              name: firstAddress.countryCode,
              shortName: firstAddress.countryCode),
          administrativeAreaLevel2: AddressComponent(
              name: firstAddress.countryCode,
              shortName: firstAddress.countryCode),
          city: AddressComponent(
              name: firstAddress.countryCode,
              shortName: firstAddress.countryCode),
          subLocalityLevel1: AddressComponent(
              name: firstAddress.countryCode,
              shortName: firstAddress.countryCode),
          subLocalityLevel2: AddressComponent(
              name: firstAddress.countryCode,
              shortName: firstAddress.countryCode),
        );
      });
    } catch (e) {
      printError('Exception throwed by map package with YANDEX: $e');
    }
  }

  /// Moves the camera to the provided location and updates other UI features to
  /// match the location.
  void moveToLocation(PlaceLatLng latLng, {required bool isNeedToGeocode}) {
    if (widget.mapProvider == MapProvider.google) {
      googleMapController?.animateCamera(
        google.CameraUpdate.newCameraPosition(
          google.CameraPosition(
              target: google.LatLng(latLng.latitude, latLng.longitude),
              zoom: 17.0),
        ),
      );
    } else if (widget.mapProvider == MapProvider.osm) {
      osmMapController?.move(latLng.toOsmLatLng(), 17.0);
    }

    if (isNeedToGeocode) {
      reverseGeocodeLatLng(latLng.toGoogleLatLong());
    }
    // getNearbyPlaces(latLng);
  }

  void moveToCurrentUserLocation({bool shouldSetMarkerInCenter = false}) {
    if (widget.initialLocation != null) {
      moveToLocation(widget.initialLocation!, isNeedToGeocode: true);

      return;
    }

    Location().getLocation().then((locationData) {
      var target =
          google.LatLng(locationData.latitude!, locationData.longitude!);
      moveToLocation(target.toPlaceLatLng(), isNeedToGeocode: true);
    }).catchError((dynamic error) {
      printError(error.toString());
    });
  }

  void printError(String error) {
    print('\x1B[31m$error\x1B[0m');
  }
}
