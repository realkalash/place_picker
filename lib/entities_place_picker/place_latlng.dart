import 'package:google_maps_flutter/google_maps_flutter.dart' as google;
import 'package:latlong2/latlong.dart' as osm;

class PlaceLatLng {
  final double latitude;
  final double longitude;

  const PlaceLatLng(this.latitude, this.longitude);

  google.LatLng toGoogleLatLong() => google.LatLng(latitude, longitude);

  osm.LatLng toOsmLatLng() => osm.LatLng(latitude, longitude);
}
