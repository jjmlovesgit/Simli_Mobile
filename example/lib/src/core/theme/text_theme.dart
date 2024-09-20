import 'package:flutter/material.dart';

/// A class that defines various text styles used throughout the application.
class AppTextTheme {
  /// Text style for the navigation bar items.
  static const TextStyle navbar = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 16,
  );

  /// Text style for displaying the total downloads count.
  static const TextStyle totalDownload = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 42,
  );

  /// Text style for the titles of achievements.
  static const TextStyle achievementTitle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 60,
    height: 1.02,
  );

  /// Text style for the descriptions of achievements.
  static const TextStyle achievementDescription = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 22,
    height: 36 / 22,
  );

  /// Text style for button titles.
  static const TextStyle buttonTitle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
    color: Colors.white,
  );

  /// Text style for the title in the feedback division.
  static const TextStyle feedbackDivTitle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 90,
    height: 1.07,
  );

  /// Text style for feedback text.
  static const TextStyle feedback = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 20,
  );

  /// Text style for customer names.
  static const TextStyle customerName = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 20,
  );

  /// Text style for the navigation bar items.
  static const TextStyle headerSidebarTitle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 14,
    height: 1.5,
  );

  /// Text style for the navigation bar items.
  static const TextStyle headerSidebarDescription = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 36 / 22,
  );

  /// Text style for the navigation bar items.
  static const TextStyle headerVision = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 36,
    height: 1.12,
  );

  /// Text style for the navigation bar items.
  static const TextStyle serviceIndex = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 64,
    height: 76 / 72,
  );

  /// Text style for the navigation bar items.
  static const TextStyle serviceTitle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 64,
    height: 1,
  );

  /// Text style for the navigation bar items.
  static const TextStyle serviceDescription = TextStyle(
    fontWeight: FontWeight.w300,
    fontSize: 18,
    height: 1.5,
  );
}
