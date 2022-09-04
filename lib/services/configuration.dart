
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesServiceProvider =
Provider<AppConfiguration>((ref) => throw UnimplementedError());

class AppConfiguration {
  AppConfiguration(this.sharedPreferences);
  final SharedPreferences sharedPreferences;

  static const onboardingCompleteKey = 'onboardingComplete';
  static const primaryColor = 'primaryColor';
  static const schoolName = 'schoolName';
  static const schoolLogoURL = 'schoolLogoURL';
  static const tenantID = 'tenantID';

  Future<void> setOnboardingComplete() async {
    await sharedPreferences.setBool(onboardingCompleteKey, true);
  }

  Future<void> setPrimaryColor(String color) async {
    await sharedPreferences.setString(primaryColor, color);
  }

  Future<void> setSchoolName(String name) async {
    await sharedPreferences.setString(schoolName, name);
  }

  Future<void> setSchoolLogoURL(String url) async {
    await sharedPreferences.setString(schoolLogoURL, url);
  }

  Future<void> setTenantID(String id) async {
    await sharedPreferences.setString(tenantID, id);
  }

  bool isOnboardingComplete() =>
      sharedPreferences.getBool(onboardingCompleteKey) ?? false;

  Color getPrimaryColor() => Color(int.parse((sharedPreferences.getString(primaryColor) ?? 'Color(0xff000000)').split('(0x')[1].split(')')[0], radix: 16));

  String getSchoolName() =>
      sharedPreferences.getString(schoolName) ?? '';

  String getSchoolLogoURL() =>
      sharedPreferences.getString(schoolLogoURL) ?? '';

  String getTenantID() =>
      sharedPreferences.getString(tenantID) ?? '';


  ///App Theme Data
  static TextStyle appBarTitleStyle = GoogleFonts.inter(
    color: Colors.black,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  static TextStyle header1 = GoogleFonts.inter(
    color: Colors.black,
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  static InputDecoration inputDecoration1 = InputDecoration(
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(width: 0, color: Colors.transparent)
      ),
      disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(width: 0, color: Colors.transparent)
      ),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(width: 0, color: Colors.transparent)
      ),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(width: 0, color: Colors.transparent)
      ),
      filled: true,
      fillColor: Colors.grey[50]
  );
}