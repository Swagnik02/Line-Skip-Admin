import 'package:flutter/material.dart';

double getWidthOfCard(BuildContext context) {
  // Get the width of the screen
  final screenWidth = MediaQuery.of(context).size.width;
  final containerPadding = 16.0;
  final cardPadding = 16.0 + 16.0;

  final cardWidth = (screenWidth - containerPadding - cardPadding) / 2 - 11;

  return cardWidth;
}
