import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'entities.dart';

/// The result returned after completing location selection.
class LocationResult {
  /// The human readable name of the location. This is primarily the
  /// name of the road. But in cases where the place was selected from Nearby
  /// places list, we use the <b>name</b> provided on the list item.
  final String? name; // or road

  /// The human readable locality of the location.
  final String? locality;

  /// Latitude/Longitude of the selected location.
  final LatLng? latLng;

  /// Formatted address suggested by Google
  final String? formattedAddress;

  final AddressComponent? country;

  final AddressComponent? city;

  final AddressComponent? administrativeAreaLevel1;

  final AddressComponent? administrativeAreaLevel2;

  final AddressComponent? subLocalityLevel1;

  final AddressComponent? subLocalityLevel2;

  final String? postalCode;

  final String? placeId;

  final String? streetNumber;

  const LocationResult({
    this.name,
    this.locality,
    this.latLng,
    this.formattedAddress,
    this.country,
    this.city,
    this.administrativeAreaLevel1,
    this.administrativeAreaLevel2,
    this.subLocalityLevel1,
    this.subLocalityLevel2,
    this.postalCode,
    this.placeId,
    this.streetNumber,
  });

  LocationResult copyWith({
    String? name,
    String? locality,
    LatLng? latLng,
    String? formattedAddress,
    AddressComponent? country,
    AddressComponent? city,
    AddressComponent? administrativeAreaLevel1,
    AddressComponent? administrativeAreaLevel2,
    AddressComponent? subLocalityLevel1,
    AddressComponent? subLocalityLevel2,
    String? postalCode,
    String? placeId,
    String? streetNumber,
  }) {
    return LocationResult(
      name: name ?? this.name,
      locality: locality ?? this.locality,
      latLng: latLng ?? this.latLng,
      formattedAddress: formattedAddress ?? this.formattedAddress,
      country: country ?? this.country,
      city: city ?? this.city,
      administrativeAreaLevel1: administrativeAreaLevel1 ?? this.administrativeAreaLevel1,
      administrativeAreaLevel2: administrativeAreaLevel2 ?? this.administrativeAreaLevel2,
      subLocalityLevel1: subLocalityLevel1 ?? this.subLocalityLevel1,
      subLocalityLevel2: subLocalityLevel2 ?? this.subLocalityLevel2,
      postalCode: postalCode ?? this.postalCode,
      placeId: placeId ?? this.placeId,
      streetNumber: streetNumber ?? this.streetNumber,
    );
  }
  /// Return copy of instance without coma in parameters
  LocationResult copyWithClearComa(){
    if(this.name != null){
      return copyWith(name: this.name?.replaceAll(',', ''));
    }
    return this;
  }
}
