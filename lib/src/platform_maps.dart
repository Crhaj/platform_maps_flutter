part of flutter_platform_maps;

typedef void MapCreatedCallback(PlatformMapController controller);

/// A Calculator.
class PlatformMap extends StatefulWidget {
  const PlatformMap({
    Key key,
    @required this.initialCameraPosition,
    this.onMapCreated,
    this.gestureRecognizers,
    this.compassEnabled = true,
    this.trafficEnabled = false,
    this.mapType,
    // this.trackingMode = TrackingMode.none,
    this.rotateGesturesEnabled = true,
    this.scrollGesturesEnabled = true,
    this.zoomGesturesEnabled = true,
    this.tiltGestureEnabled = true,
    this.myLocationEnabled = false,
    this.myLocationButtonEnabled = true,
    this.markers,
    this.onCameraMoveStarted,
    this.onCameraMove,
    this.onCameraIdle,
    this.onTap,
    this.onLongPress,
    this.minMaxZoomPreference,
  })  : assert(initialCameraPosition != null),
        super(key: key);

  final MapCreatedCallback onMapCreated;

  /// The initial position of the map's camera.
  final CameraPosition initialCameraPosition;

  /// True if the map should show a compass when rotated.
  final bool compassEnabled;

  /// Type of map tiles to be rendered.
  final MapType mapType;

  /// True if the map should display the current traffic.
  final bool trafficEnabled;

  /// The mode used to track the user location.
  // final TrackingMode trackingMode;

  /// Preferred bounds for the camera zoom level.
  ///
  /// Actual bounds depend on map data and device.
  final MinMaxZoomPreference minMaxZoomPreference;

  /// True if the map view should respond to rotate gestures.
  final bool rotateGesturesEnabled;

  /// True if the map view should respond to scroll gestures.
  final bool scrollGesturesEnabled;

  /// True if the map view should respond to zoom gestures.
  final bool zoomGesturesEnabled;

  /// True if the map view should respond to tilt gestures.
  final bool tiltGestureEnabled;

  /// Markers to be placed on the map.
  final Set<Marker> markers;

  /// Called when the camera starts moving.
  ///
  /// This can be initiated by the following:
  /// 1. Non-gesture animation initiated in response to user actions.
  ///    For example: zoom buttons, my location button, or marker clicks.
  /// 2. Programmatically initiated animation.
  /// 3. Camera motion initiated in response to user gestures on the map.
  ///    For example: pan, tilt, pinch to zoom, or rotate.
  final VoidCallback onCameraMoveStarted;

  /// Called repeatedly as the camera continues to move after an
  /// onCameraMoveStarted call.
  ///
  /// This may be called as often as once every frame and should
  /// not perform expensive operations.
  final Function onCameraMove;

  /// Called when camera movement has ended, there are no pending
  /// animations and the user has stopped interacting with the map.
  final VoidCallback onCameraIdle;

  /// Called every time a [AppleMap] is tapped.
  final Function onTap;

  /// Called every time a [AppleMap] is long pressed.
  final Function onLongPress;

  /// True if a "My Location" layer should be shown on the map.
  ///
  /// This layer includes a location indicator at the current device location,
  /// as well as a My Location button.
  /// * The indicator is a small blue dot if the device is stationary, or a
  /// chevron if the device is moving.
  /// * The My Location button animates to focus on the user's current location
  /// if the user's location is currently known.
  ///
  /// Enabling this feature requires adding location permissions to both native
  /// platforms of your app.
  /// * On Android add either
  /// `<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />`
  /// or `<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />`
  /// to your `AndroidManifest.xml` file. `ACCESS_COARSE_LOCATION` returns a
  /// location with an accuracy approximately equivalent to a city block, while
  /// `ACCESS_FINE_LOCATION` returns as precise a location as possible, although
  /// it consumes more battery power. You will also need to request these
  /// permissions during run-time. If they are not granted, the My Location
  /// feature will fail silently.
  /// * On iOS add a `NSLocationWhenInUseUsageDescription` key to your
  /// `Info.plist` file. This will automatically prompt the user for permissions
  /// when the map tries to turn on the My Location layer.
  final bool myLocationEnabled;

  /// Enables or disables the my-location button.
  ///
  /// The my-location button causes the camera to move such that the user's
  /// location is in the center of the map. If the button is enabled, it is
  /// only shown when the my-location layer is enabled.
  ///
  /// By default, the my-location button is enabled (and hence shown when the
  /// my-location layer is enabled).
  ///
  /// See also:
  ///   * [myLocationEnabled] parameter.
  final bool myLocationButtonEnabled;

  /// Which gestures should be consumed by the map.
  ///
  /// It is possible for other gesture recognizers to be competing with the map on pointer
  /// events, e.g if the map is inside a [ListView] the [ListView] will want to handle
  /// vertical drags. The map will claim gestures that are recognized by any of the
  /// recognizers on this list.
  ///
  /// When this set is empty or null, the map will only handle pointer events for gestures that
  /// were not claimed by any other gesture recognizer.
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  @override
  _PlatformMapState createState() => _PlatformMapState();
}

class _PlatformMapState extends State<PlatformMap> {
  @override
  Widget build(BuildContext context) {
    print(widget.mapType);
    if (Platform.isAndroid) {
      return googleMaps.GoogleMap(
        initialCameraPosition:
            widget.initialCameraPosition.googleMapsCameraPosition,
        compassEnabled: widget.compassEnabled,
        mapType: _getGoogleMapType(),
        markers: Marker.toGoogleMapsMarkerSet(widget.markers),
        gestureRecognizers: widget.gestureRecognizers,
        onCameraIdle: widget.onCameraIdle,
        myLocationButtonEnabled: widget.myLocationButtonEnabled,
        myLocationEnabled: widget.myLocationEnabled,
        onCameraMoveStarted: widget.onCameraMoveStarted,
        tiltGesturesEnabled: widget.tiltGestureEnabled,
        rotateGesturesEnabled: widget.rotateGesturesEnabled,
        zoomGesturesEnabled: widget.zoomGesturesEnabled,
        scrollGesturesEnabled: widget.scrollGesturesEnabled,
        onMapCreated: _onGoogleMapCreated,
        onCameraMove: widget.onCameraMove,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        trafficEnabled: widget.trafficEnabled,
        minMaxZoomPreference:
            widget.minMaxZoomPreference.googleMapsZoomPreference ??
                MinMaxZoomPreference.unbounded,
      );
    } else if (Platform.isIOS) {
      return appleMaps.AppleMap(
        initialCameraPosition:
            widget.initialCameraPosition.appleMapsCameraPosition,
        compassEnabled: widget.compassEnabled,
        mapType: _getAppleMapType(),
        annotations: Marker.toAppleMapsAnnotationSet(widget.markers),
        gestureRecognizers: widget.gestureRecognizers,
        onCameraIdle: widget.onCameraIdle,
        myLocationButtonEnabled: widget.myLocationButtonEnabled,
        myLocationEnabled: widget.myLocationEnabled,
        onCameraMoveStarted: widget.onCameraMoveStarted,
        pitchGesturesEnabled: widget.tiltGestureEnabled,
        rotateGesturesEnabled: widget.rotateGesturesEnabled,
        zoomGesturesEnabled: widget.zoomGesturesEnabled,
        scrollGesturesEnabled: widget.scrollGesturesEnabled,
        onMapCreated: _onAppleMapCreated,
        onCameraMove: widget.onCameraMove,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        trafficEnabled: widget.trafficEnabled,
        minMaxZoomPreference:
            widget.minMaxZoomPreference.appleMapsZoomPreference ??
                MinMaxZoomPreference.unbounded,
      );
    } else {
      return Text("Platform not yet implemented");
    }
  }

  _onGoogleMapCreated(googleMaps.GoogleMapController controller) {
    widget.onMapCreated(PlatformMapController(controller));
  }

  _onAppleMapCreated(appleMaps.AppleMapController controller) {
    widget.onMapCreated(PlatformMapController(controller));
  }

  appleMaps.MapType _getAppleMapType() {
    if (widget.mapType == MapType.normal) {
      return appleMaps.MapType.standard;
    } else if (widget.mapType == MapType.satellite) {
      return appleMaps.MapType.satellite;
    } else if (widget.mapType == MapType.hybrid) {
      return appleMaps.MapType.hybrid;
    }
    return appleMaps.MapType.standard;
  }

  googleMaps.MapType _getGoogleMapType() {
    if (widget.mapType == MapType.normal) {
      return googleMaps.MapType.normal;
    } else if (widget.mapType == MapType.satellite) {
      return googleMaps.MapType.satellite;
    } else if (widget.mapType == MapType.hybrid) {
      return googleMaps.MapType.hybrid;
    }
    return googleMaps.MapType.normal;
  }
}
