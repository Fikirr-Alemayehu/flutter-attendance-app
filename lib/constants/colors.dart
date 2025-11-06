import 'package:flutter/material.dart';

const kcGreen = Color.fromARGB(255, 38, 188, 135);
const kcRed = Colors.red;
const kcDarkRed = Color.fromARGB(255, 106, 10, 4);
var kcDarkBlue = Colors.blue.shade900;
const kcAppBg = Color(0xFFF7F7F7);
const kcFont = Colors.black54;
const kcFontBold = Colors.black;
const kcFontBolder = Color.fromARGB(255, 20, 20, 20);
const kcLink = Color.fromARGB(255, 69, 147, 212);
const kcLightGrey = Color.fromARGB(255, 221, 216, 216);
const kcGrey = Colors.grey;
const kcOrange = Colors.orange;
const kcWhite = Colors.white;
const kcBlack = Colors.black;
const kcBlackish = Color.fromARGB(255, 60, 54, 54);
const kcBlueAccent = Colors.blueAccent;
const kcSeatReservedColor = Color.fromARGB(255, 26, 149, 166);
const kcSeatRedeemedColor = Colors.purple;
const kcWhiteSmoke = Color.fromARGB(255, 227, 225, 225);
const kcBlackSmoke = Color.fromARGB(255, 56, 55, 55);

Color get kcLightWhite => kcWhite.withValues(alpha: 0.9);

Color kcPrimary(BuildContext context) => Theme.of(context).primaryColor;
Color kcOnPrimary(BuildContext context) =>
    Theme.of(context).colorScheme.onPrimary;
Color kcOnErrorContainer(BuildContext context) =>
    Theme.of(context).colorScheme.onErrorContainer;
Color kcSecondary(BuildContext context) =>
    Theme.of(context).colorScheme.secondary;
Color kcTertiary(BuildContext context) =>
    Theme.of(context).colorScheme.tertiary;
Color kcBackground(BuildContext context) =>
    Theme.of(context).colorScheme.surface;
Color kcOnBackground(BuildContext context) =>
    Theme.of(context).colorScheme.onSurface;
Color kcSurfaceTint(BuildContext context) =>
    Theme.of(context).colorScheme.surfaceTint;
Color kcPrimaryContainer(BuildContext context) =>
    Theme.of(context).colorScheme.primaryContainer;
Color kcOnPrimaryContainer(BuildContext context) =>
    Theme.of(context).colorScheme.onPrimaryContainer;
Color kcSecondaryContainer(BuildContext context) =>
    Theme.of(context).colorScheme.secondaryContainer;
Color kcOnSecondaryContainer(BuildContext context) =>
    Theme.of(context).colorScheme.onSecondaryContainer;
Color kcTertiaryContainer(BuildContext context) =>
    Theme.of(context).colorScheme.tertiaryContainer;
Color kcOnTertiaryContainer(BuildContext context) =>
    Theme.of(context).colorScheme.onTertiaryContainer;
Color kcHighlight(BuildContext context) => Theme.of(context).highlightColor;
Color kcHint(BuildContext context) => Theme.of(context).hintColor;

Color kcError(BuildContext context) => Theme.of(context).colorScheme.error;

Color kcGreyish(BuildContext context) =>
    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8);

Color kcLightGreyish(BuildContext context) =>
    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65);
Color kcVeryLightGreyish(BuildContext context) =>
    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2);

Color kcXVeryLightGreyish(BuildContext context) =>
    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1);

Color kcXXVeryLightGreyish(BuildContext context) =>
    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.065);

Color kcHighlightBackground(BuildContext context) =>
    kcBackground(context).withValues(alpha: 0.8);

Color kcSmoke(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? kcBlackSmoke
        : kcWhiteSmoke;
