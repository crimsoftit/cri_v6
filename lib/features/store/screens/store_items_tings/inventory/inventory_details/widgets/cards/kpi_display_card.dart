import 'package:cri_v6/common/widgets/anime/animated_digit_widget.dart';
import 'package:cri_v6/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:cri_v6/utils/constants/colors.dart';
import 'package:cri_v6/utils/constants/sizes.dart';
import 'package:cri_v6/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

class CKPIDisplayCard extends StatelessWidget {
  const CKPIDisplayCard({
    super.key,
    required this.animeDigit,
    this.anotherTitleWidget,
    this.bgColor,
    this.fractionDigits,
    this.leadingWidget,
    this.onCardTap,
    this.prefixLabel,
    this.subTitle,
    this.trailingWidget,
    this.titleWidget,
  });

  final Color? bgColor;
  final double animeDigit;
  final int? fractionDigits;
  final String? prefixLabel, subTitle;
  final void Function()? onCardTap;
  final Widget? anotherTitleWidget, leadingWidget, titleWidget, trailingWidget;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onCardTap,
      child: CRoundedContainer(
        bgColor: bgColor ?? CColors.transparent,
        width: CHelperFunctions.screenWidth() * .88,
        child: ListTile(
          leading:
              leadingWidget ?? Icon(Icons.attach_money, color: CColors.rBrown),

          title: Row(
            children: [
              Text(
                prefixLabel ?? 'kES',
                style: Theme.of(context).textTheme.labelSmall!.apply(
                  fontFeatures: [FontFeature.superscripts()],
                  fontSizeFactor: .9,
                ),
              ),
              CAnimatedDigitWidget(
                fractionDigits: fractionDigits ?? 1,
                prefix: '',
                txtStyle: Theme.of(context).textTheme.titleMedium!.apply(
                  color: CColors.rOrange,
                  fontWeightDelta: 2,
                ),
                value: animeDigit,
              ),
              anotherTitleWidget ?? const SizedBox.shrink(),
            ],
          ),
          subtitle: Text(subTitle ?? 'Total sales'),

          trailing:
              trailingWidget ??
              Icon(
                Icons.info_outline,
                color: CColors.rBrown,
                size: CSizes.iconSm,
              ),
        ),
      ),
    );
  }
}
