import 'package:cri_v6/utils/constants/colors.dart';
import 'package:cri_v6/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

class CFormDivider extends StatelessWidget {
  const CFormDivider({
    super.key,
    required this.dividerText,
    this.dividerColor,
    this.dividerTxtColor,
    this.dividerTxtFontSizeFactor,
    this.line1EndIndent,
    this.line1StartIndent,
    this.line2EndIndent,
    this.line2StartIndent,
  });

  final Color? dividerColor, dividerTxtColor;
  final String dividerText;
  final double? dividerTxtFontSizeFactor,
      line1EndIndent,
      line1StartIndent,
      line2EndIndent,
      line2StartIndent;

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = CHelperFunctions.isDarkMode(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Divider(
            color:
                dividerColor ?? (isDarkTheme ? CColors.grey : CColors.darkGrey),
            thickness: 0.3,
            indent: line1StartIndent ?? 60.0,
            endIndent: line1EndIndent ?? 5.0,
          ),
        ),
        Text(
          dividerText,
          style: Theme.of(context).textTheme.labelMedium?.apply(
            color: dividerTxtColor ?? CColors.darkGrey,
            fontSizeFactor: dividerTxtFontSizeFactor ?? 0.8,
          ),
        ),
        Flexible(
          child: Divider(
            color:
                dividerColor ?? (isDarkTheme ? CColors.darkGrey : CColors.grey),
            thickness: 0.3,
            indent: line2StartIndent ?? 5,
            endIndent: line2EndIndent ?? 60,
          ),
        ),
      ],
    );
  }
}
