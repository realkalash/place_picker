import 'package:google_maps_flutter/google_maps_flutter.dart' as google;
import 'package:latlong2/latlong.dart' as latLong;
import 'package:place_picker/entities_place_picker/place_latlng.dart';

extension LatLngGoogleExtension on latLong.LatLng {
  google.LatLng toGoogleLatLong() =>
      google.LatLng(this.latitude, this.longitude);
  PlaceLatLng toPlaceLatLng() => PlaceLatLng(latitude, longitude);
}

extension LatLngOsmExtension on google.LatLng {
  latLong.LatLng toOsmLatLong() =>
      latLong.LatLng(this.latitude, this.longitude);

  PlaceLatLng toPlaceLatLng() => PlaceLatLng(latitude, longitude);
}
