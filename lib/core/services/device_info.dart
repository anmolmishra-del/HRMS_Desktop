import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

Future<String> getDeviceName() async {
  final deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    final android = await deviceInfo.androidInfo;
    return "${android.brand} ${android.model}";
  } else if (Platform.isIOS) {
    final ios = await deviceInfo.iosInfo;
    return ios.utsname.machine ?? "iOS Device";
  }

  return "Unknown Device";
}
Future<String> getIpAddress() async {
  try {
    final res = await Dio().get("https://api.ipify.org?format=json");
    return res.data["ip"] ?? "0.0.0.0";
  } catch (e) {
    return "0.0.0.0";
  }
}

Future<String> getLocation() async {
  try {
    /// 1. Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return "Location services are disabled";
    }

    /// 2. Check permission
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return "Location permission denied";
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return "Location permission permanently denied";
    }

    /// 3. Get position with timeout (important to avoid UI freeze)
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
    ).timeout(const Duration(seconds: 10));

    /// 4. Reverse geocoding (can fail, so wrap separately)
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        return placemarks.first.locality ??
            placemarks.first.subAdministrativeArea ??
            "Unknown location";
      }
    } catch (e) {
      return "Location fetched, but address failed";
    }

    return "Unknown location";
  } catch (e) {
    return "Failed to get location: $e";
  }

}