import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  double dynamicWidth(double val) => MediaQuery.of(this).size.width / val;
  double dynamicHeight(double val) => MediaQuery.of(this).size.height / val;

  ThemeData get theme => Theme.of(this);
}

extension NumberHighExtension on BuildContext {
  double get lowHighValue => dynamicHeight(0.01);
  double get mediumHighValue => dynamicHeight(0.03);
  double get bigHighValue => dynamicHeight(0.05);
}

extension NumberWidthExtension on BuildContext {
  double get lowWidthValue => dynamicWidth(0.01);
  double get mediumWidthValue => dynamicWidth(0.03);
  double get bigWidthValue => dynamicWidth(0.05);
}

extension PaddingHighExtension on BuildContext {
  EdgeInsets get paddingLowHigh => EdgeInsets.all(lowHighValue);
  EdgeInsets get paddingMediumHigh => EdgeInsets.all(mediumHighValue);
  EdgeInsets get paddingBigHigh => EdgeInsets.all(bigHighValue);
}

extension PaddingWidthExtension on BuildContext {
  EdgeInsets get paddingLowWidth => EdgeInsets.all(lowWidthValue);
  EdgeInsets get paddingMediumWidth => EdgeInsets.all(mediumWidthValue);
  EdgeInsets get paddingBigWidth => EdgeInsets.all(bigWidthValue);
}

extension EmptyWidget on BuildContext {
  Widget get emptyWidgetHeight => SizedBox(height: lowHighValue);
}
