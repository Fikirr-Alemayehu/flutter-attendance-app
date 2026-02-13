// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:glc/constants/colors.dart';
import 'package:glc/constants/dimention.dart';
import 'package:glc/constants/font_style.dart';
import 'package:glc/constants/icons.dart';

class AppDialogUtils {
  static Future<dynamic> showGenDialog({
    required BuildContext context,
    required Function onOkay,
    Function? onCancel,
    required String content,
    Widget? contentWidget,
    String okayText = "OKAY",
    String cancelText = "CANCEL",
    bool barrierDismissible = true,
    bool keepdialogAfterSubmit = false,
    String title = "Confirm",
  }) async {
    return await showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () => Future.value(false),
          child: SimpleDialog(
            title: Text("dialog", style: kfBodyMedium(context)),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32.0)),
            ),
            elevation: 10,
            children: [
              SimpleDialogOption(
                child: Container(child: contentWidget ?? Text(content)),
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.only(bottom: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onCancel != null)
                      MaterialButton(
                        padding: const EdgeInsets.all(0),
                        child: Text(cancelText),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                          onCancel();
                        },
                      ),
                    MaterialButton(
                      child: Text(okayText),
                      onPressed: () async {
                        if (!keepdialogAfterSubmit) {
                          Navigator.of(context).pop(true);
                        }
                        await onOkay();
                      },
                    ),
                  ],
                ),
              ),
            ],
            //backgroundColor: Colors.green,
          ),
        );
      },
    );
  }

  static Future<dynamic> showBottomModalSheet({
    required Widget child,
    required BuildContext context,
    Color? backgroundColor,
    String? titleText,
    double? initHeight,
    double? minHeight,
    double? maxHeight,
    bool isDismissible = true,
    Color? titleColor,
    bool isCollapsible = true,
  }) async {
    return await showFlexibleBottomSheet(
      initHeight: initHeight ?? minHeight ?? 0.3,
      minHeight: minHeight,
      maxHeight: maxHeight ?? 0.9,
      isCollapsible: isCollapsible,
      context: context,
      isExpand: true,
      isDismissible: isDismissible,
      bottomSheetColor: Colors.transparent,
      builder:
          (
            BuildContext context,
            ScrollController scrollController,
            double bottomSheetOffset,
          ) {
            return Container(
              width: kdScreenWidth(context),
              decoration: BoxDecoration(
                color: backgroundColor ?? kcBackground(context),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(kdPadding),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                width: 80,
                                height: 7,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    kdContainerRadius,
                                  ),
                                  color: kcVeryLightGreyish(context),
                                ),
                              ),
                            ),
                            if (titleText != null) ...[
                              SizedBox(
                                width: kdScreenWidth(context),
                                child: Text(
                                  titleText,
                                  textAlign: TextAlign.center,
                                  style: kfBodyMedium(
                                    context,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Divider(),
                              kdSpaceSmall.height,
                            ],
                            child,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
    );
  }

  static Future<DateTime?> singleDateSelectorDialog({
    required BuildContext context,
    required DateTime initalDateTime,
    DateTime? selectedDate,
  }) async {
    return await showDatePicker(
      context: context,
      initialDate: initalDateTime,
      firstDate: initalDateTime,
      currentDate: selectedDate,
      lastDate: initalDateTime.add(const Duration(days: 360)),
    );
  }

  static Future<DateTimeRange?> selectDateTimeRange({
    required BuildContext context,
    required DateTime initalDateTime,
    DateTimeRange? initialDateRange,
  }) async {
    return await showDateRangePicker(
      context: context,
      firstDate: initalDateTime,
      initialDateRange: initialDateRange,
      lastDate: initalDateTime.add(const Duration(days: 360)),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
  }

  static Future<dynamic> dialogWithTextField({
    required BuildContext context,
    String initalText = "",
    String title = "Confirm",
    String okayText = "Okay",
    String hintText = "Type here...",
  }) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController controller = TextEditingController();
        controller.text = initalText;
        return SimpleDialog(
          title: Text(title, style: kfBodyMedium(context)),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0)),
          ),
          elevation: 10,
          children: [
            SimpleDialogOption(
              child: TextField(
                readOnly: false,
                maxLines: null,
                controller: controller,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(0),
                  labelText: hintText,
                  prefixIcon: const Icon(kiEdit),
                  hintStyle: kfLabelMedium(context),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey, width: .5),
                  ),
                ),
                onChanged: (String s) {},
              ),
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.only(bottom: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MaterialButton(
                    padding: const EdgeInsets.all(0),
                    child: const Text("CANCEL"),
                    onPressed: () {
                      Navigator.of(context).pop(null);
                    },
                  ),
                  MaterialButton(
                    child: Text(okayText.toUpperCase()),
                    onPressed: () {
                      Navigator.of(context).pop(controller.text);
                    },
                  ),
                ],
              ),
            ),
          ],
          //backgroundColor: Colors.green,
        );
      },
    );
  }

  static Widget wrapInGradient({
    required var image,
    bool beginFromTop = true,
    bool gradBothEnds = false,
    List<Color> defaultColor = const [Colors.transparent, Colors.black],
  }) {
    return Stack(
      fit: StackFit.expand,
      children: [
        image,
        Container(
          height: 500,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradBothEnds
                  ? [
                      Colors.black,
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black,
                    ]
                  : defaultColor,
              stops: gradBothEnds ? [0, 0.4, 0.5, 1] : [0.5, 1],
              begin: beginFromTop
                  ? Alignment.bottomCenter
                  : Alignment.topCenter,
              end: beginFromTop ? Alignment.topCenter : Alignment.bottomCenter,
              tileMode: TileMode.clamp,
            ),
          ),
        ),
      ],
    );
  }

  static Future<dynamic> bottomModalHandlerWithNoScroll({
    required Widget child,
    required BuildContext context,
    Color? backgroundColor,
    String? titleText,
    double? minHeight,
    double? maxHeight,
    bool isDismissible = true,
    Color? titleColor,
    bool isCollapsible = true,
  }) async {
    return await showFlexibleBottomSheet(
      initHeight: maxHeight,
      minHeight: minHeight,
      maxHeight: maxHeight ?? 0.9,
      isCollapsible: isCollapsible,
      context: context,
      isExpand: true,
      isDismissible: isDismissible,
      bottomSheetColor: Colors.transparent,
      builder:
          (
            BuildContext context,
            ScrollController scrollController,
            double bottomSheetOffset,
          ) {
            return Container(
              width: kdScreenWidth(context),
              decoration: BoxDecoration(
                color: backgroundColor ?? kcBackground(context),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: child,
            );
          },
    );
  }

  static List<Widget> buildLanguageOptions(
    BuildContext context,
    List<Map<String, dynamic>> supportedLangs,
    String selectedLangCode,
    Function(String) onSelect,
  ) {
    return List<Widget>.from(
      supportedLangs.map((lang) {
        final String name = lang["name"];
        final String code = lang["code"];
        final String base64ImageString = lang["flag"];
        final Uint8List decodedBytes = base64Decode(
          base64ImageString.split(',').last,
        );

        return GestureDetector(
          onTap: () => onSelect(code),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: kcSmoke(context),
              borderRadius: BorderRadius.circular(12),
              border: selectedLangCode == code
                  ? Border.all(color: kcPrimary(context), width: 1)
                  : null,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: MemoryImage(decodedBytes),
                  radius: 20,
                ),
                const SizedBox(width: 12),
                Text(name, style: kfBodyMedium(context)),
              ],
            ),
          ),
        );
      }),
    );
  }
}
