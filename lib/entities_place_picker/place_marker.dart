import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google;
import 'package:flutter_map/flutter_map.dart' as osm;
import 'package:latlong2/latlong.dart';
import 'package:place_picker/extensions.dart';

typedef ValueChanged<T> = void Function(T value);

class PlaceMarker {
  /// Uniquely identifies a [Marker].
  final String markerId;

  /// The opacity of the marker, between 0.0 and 1.0 inclusive.
  ///
  /// 0.0 means fully transparent, 1.0 means fully opaque.
  final double alpha;

  /// The icon image point that will be placed at the [position] of the marker.
  ///
  /// The image point is specified in normalized coordinates: An anchor of
  /// (0.0, 0.0) means the top left corner of the image. An anchor
  /// of (1.0, 1.0) means the bottom right corner of the image.
  final Offset anchor;

  /// True if the marker icon consumes tap events. If not, the map will perform
  /// default tap handling by centering the map on the marker and displaying its
  /// info window.
  final bool consumeTapEvents;

  /// True if the marker is draggable by user touch events.
  final bool draggable;

  /// True if the marker is rendered flatly against the surface of the Earth, so
  /// that it will rotate and tilt along with map camera movements.
  final bool flat;

  /// A description of the bitmap used to draw the marker icon.
  final Icon icon;

  /// Geographical location of the marker.
  final LatLng position;

  /// Rotation of the marker image in degrees clockwise from the [anchor] point.
  final double rotation;

  /// True if the marker is visible.
  final bool visible;

  /// The z-index of the marker, used to determine relative drawing order of
  /// map overlays.
  ///
  /// Overlays are drawn in order of z-index, so that lower values means drawn
  /// earlier, and thus appearing to be closer to the surface of the Earth.
  final double zIndex;

  /// Callbacks to receive tap events for markers placed on this map.
  final VoidCallback? onTap;

  /// Signature reporting the new [LatLng] at the start of a drag event.
  final ValueChanged<LatLng>? onDragStart;

  /// Signature reporting the new [LatLng] at the end of a drag event.
  final ValueChanged<LatLng>? onDragEnd;

  /// Signature reporting the new [LatLng] during the drag event.
  final ValueChanged<LatLng>? onDrag;

  const PlaceMarker({
    required this.markerId,
    required this.position,
    this.alpha = 1.0,
    this.anchor = const Offset(0.5, 1.0),
    this.consumeTapEvents = false,
    this.draggable = false,
    this.flat = false,
    this.icon = const Icon(Icons.place),
    this.rotation = 0.0,
    this.visible = true,
    this.zIndex = 0.0,
    this.onTap,
    this.onDrag,
    this.onDragStart,
    this.onDragEnd,
  });

  google.Marker toGoogleMarker() {
    return google.Marker(
      markerId: google.MarkerId(markerId),
      position: position.toGoogleLatLong(),
      alpha: alpha,
      anchor: anchor,
      consumeTapEvents: consumeTapEvents,
      draggable: draggable,
      flat: flat,
      // icon: not supported yet
      rotation: rotation,
      visible: visible,
      zIndex: zIndex,
      onTap: onTap,
      onDrag: onDrag == null
          ? null
          : (google.LatLng value) => onDrag?.call(value.toOsmLatLong()),
      onDragStart: onDragStart == null
          ? null
          : (google.LatLng value) => onDragStart?.call(value.toOsmLatLong()),
      onDragEnd: onDragEnd == null
          ? null
          : (google.LatLng value) => onDragEnd?.call(value.toOsmLatLong()),
    );
  }

  Widget toWidget() {
    return Container(
      width: 32,
      height: 32,
      padding: EdgeInsets.all(4.0),
      child: FittedBox(child: icon),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
    );
  }

  osm.Marker toOsmMarker() {
    return osm.Marker(
      point: this.position,
      builder: (context) => toWidget(),
      height: 32,
      width: 32,
      rotate: true,
    );
  }
}
