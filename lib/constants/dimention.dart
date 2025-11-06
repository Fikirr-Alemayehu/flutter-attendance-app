import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const double kdSpaceTiny = 2.5;
const double kdSpaceSmall = 5;
const double kdSpace = 10;
const double kdSpaceLarge = 15;
const double kdSpaceXLarge = 20;
const double kdSpaceXXLarge = 25;
const double kdSpaceXXXLarge = 50;

//pad and margin
const double kdPaddingTiny = 2;
const double kdPaddingSmall = 5;
const double kdPadding = 8;
const double kdPaddingLarge = 16;

const double kdMarginSmall = 5;
const double kdMargin = 8;
const double kdMarginLarge = 16;

//images
const double kdXLargeSquareAvatar = 128;
const double kdLargeSquareAvatar = 64;
const double kdMediumSquareAvatar = 85;
const double kdSquareAvatar = 52;
const double kdSmallSquareAvatar = 32;
const double kdAppImageSize = 100;
const double kdSmallCompanyIcon = 100;

//appbar
const double kdAppBarSliderHeight = 300;
const double kdAppBarCollapsedHeight = 120;

const double kdWebAppMaxWidth = 480.0;

//radius
const double kdCardRadius = 5;
const double kdContainerRadius = 10;
const double kdRoundedRadius = 15;
const double kdScaffoldRoundedRadius = 21;

const double kdCircleAvatarSmall = 14;
const double kdCircleAvatar = 18;
const double kdCircleAvatarLarge = 22;
const double kdCircleAvatarMedium = 36;
const double kdCircleAvatarXLarge = 64;

//sizes
const double kdRectBoxWidth = 96;
const double kdRectBoxHeight = 106;
const double kdRectBoxWidthSmall = kdRectBoxWidth - kdRectBoxWidth * .2;
const double kdRectBoxHeightSmall = kdRectBoxHeight - kdRectBoxHeight * .15;
const double kdSectorIconTileSize = 200;
const double kdSectorIconSize = 30;
const double kdSectorIconSizeSmall = 25;

//cinema
const double kdMoviePosterItemHeight = 180;
const double kdMovieItemHeight = 160;

const double kdSeatItemWidth = 24;
const double kdSeatItemHeight = 24;

const double kdQrHeight = 280;

const double kdQrHeightLarge = 350;

const double kdPortraitImageHeight = 250;
const double kdPortraitImageHeightSmall = 230;
const double kdPortraitImageWidth = 100;

const double kdSeatLegenedWidthLarge = 36;
const double kdSeatLegenedWidthSmall = 30;
const double kdSeatLegenedHeightSmall = 30;
const double kdCuisineSize = 64;

extension KdSpace on num {
  get width => SizedBox(width: toDouble());
  get height => SizedBox(
        height: toDouble(),
      );
}

kdScreenWidth(BuildContext context) {
  if (kIsWeb) {
    return min(kdWebAppMaxWidth, MediaQuery.sizeOf(context).width);
  }
  return MediaQuery.sizeOf(context).width;
}

kdScreenHeight(BuildContext context) {
  return MediaQuery.sizeOf(context).height;
}
