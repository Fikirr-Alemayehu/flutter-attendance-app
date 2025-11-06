//font
import 'package:flutter/material.dart';
import 'package:glc/constants/colors.dart';
import 'package:google_fonts/google_fonts.dart';

const double kfTiny = 10;
const double kfSmall = 12;
const double kfNormal = 14;
const double kfLarge = 17;
const double kfXLarge = 18;
const double kfXXLarge = 21;
const double kfXXXLarge = 24;
const double kfXXXXLarge = 27;

const double kfIconNormal = 18;
const double kfIconSmall = 14;
const double kfIconLarge = 22;

TextStyle bodyStyle = GoogleFonts.roboto(color: kcFont, fontSize: kfNormal);

TextStyle buttonStyle = GoogleFonts.roboto(
  color: kcWhite,
  fontSize: kfNormal,
  fontWeight: FontWeight.w600,
);

TextStyle? kfLabelTiny(
  BuildContext context, {
  Color? color,
  FontWeight? fontWeight,
}) => Theme.of(context).textTheme.labelSmall?.copyWith(
  color: color,
  fontWeight: fontWeight,
  fontSize: 9,
);

TextStyle? kfLabelSmall(
  BuildContext context, {
  Color? color,
  FontWeight? fontWeight,
}) => Theme.of(
  context,
).textTheme.labelSmall?.copyWith(color: color, fontWeight: fontWeight);

TextStyle? kfLabelMedium(
  BuildContext context, {
  Color? color,
  FontWeight? fontWeight,
}) => Theme.of(
  context,
).textTheme.labelMedium?.copyWith(color: color, fontWeight: fontWeight);

TextStyle? kfLabelLarge(
  BuildContext context, {
  Color? color,
  FontWeight? fontWeight,
}) => Theme.of(
  context,
).textTheme.labelLarge?.copyWith(color: color, fontWeight: fontWeight);

TextStyle? kfBodySmall(
  BuildContext context, {
  Color? color,
  FontWeight? fontWeight,
}) => Theme.of(
  context,
).textTheme.bodySmall?.copyWith(color: color, fontWeight: fontWeight);
TextStyle? kfBodyMedium(
  BuildContext context, {
  Color? color,
  FontWeight? fontWeight,
}) => Theme.of(
  context,
).textTheme.bodyMedium?.copyWith(color: color, fontWeight: fontWeight);
TextStyle? kfBodyLarge(
  BuildContext context, {
  Color? color,
  FontWeight? fontWeight,
}) => Theme.of(
  context,
).textTheme.bodyLarge?.copyWith(color: color, fontWeight: fontWeight);

TextStyle? kfBrandStyle(
  BuildContext context, {
  Color? color,
  FontWeight? fontWeight,
}) {
  return Theme.of(context).textTheme.titleMedium?.copyWith(
    color: color,
    fontWeight: fontWeight,
    fontSize: 18,
  );
}

TextStyle? kfTitleSmall(
  BuildContext context, {
  Color? color,
  FontWeight? fontWeight,
}) {
  return Theme.of(
    context,
  ).textTheme.titleSmall?.copyWith(color: color, fontWeight: fontWeight);
}

TextStyle? kfHeadlineMedium(
  BuildContext context, {
  Color? color,
  FontWeight? fontWeight,
}) => Theme.of(
  context,
).textTheme.headlineMedium?.copyWith(color: color, fontWeight: fontWeight);
TextStyle? kfHeadlineSmall(
  BuildContext context, {
  Color? color,
  FontWeight? fontWeight,
}) => Theme.of(
  context,
).textTheme.headlineSmall?.copyWith(color: color, fontWeight: fontWeight);
