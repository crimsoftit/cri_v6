import 'package:cri_v6/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:cri_v6/utils/constants/colors.dart';
import 'package:cri_v6/utils/constants/sizes.dart';
import 'package:cri_v6/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CAmountTxtField extends StatelessWidget {
  const CAmountTxtField({
    super.key,
    this.txtFieldHeight = 45.0,
    required this.fieldController,
    required this.txtFieldWidth,
    this.focusedBorderColor,
    this.labelTxt,
    required this.onValueChanged,
  });

  final double txtFieldWidth, txtFieldHeight;
  final Color? focusedBorderColor;
  final String? labelTxt;
  final TextEditingController fieldController;
  final void Function(String?) onValueChanged;

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = CHelperFunctions.isDarkMode(context);

    return CRoundedContainer(
      width: txtFieldWidth,
      height: txtFieldHeight,
      bgColor: isDarkTheme
          ? CColors.rBrown.withValues(
              alpha: 0.3,
            )
          : CColors.white,
      child: TextFormField(
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: false,
        ),
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'^\d+(\.\d*)?')),
        ],
        // autofocus: checkoutController
        //     .setFocusOnAmtIssuedField
        //     .value,
        autofocus: false,
        controller: fieldController,
        decoration: InputDecoration(
          focusColor: CColors.rBrown.withValues(
            alpha: 0.3,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              CSizes.cardRadiusLg,
            ),
            borderSide: BorderSide(
              color: CColors.grey,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color:
                  focusedBorderColor ??
                  CColors.rBrown.withValues(
                    alpha: 0.3,
                  ),
            ),
            borderRadius: BorderRadius.circular(
              CSizes.cardRadiusLg,
            ),
          ),
          //border: InputBorder.none,
          labelText: labelTxt ?? 'Enter amount issued by customer',
        ),
        style: const TextStyle(
          fontWeight: FontWeight.normal,
        ),
        onChanged: onValueChanged,
        textAlign: TextAlign.center,
      ),
    );
  }
}
