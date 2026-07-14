import 'package:cri_v6/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:cri_v6/common/widgets/login_signup/form_divider.dart';
import 'package:cri_v6/features/personalization/controllers/user_controller.dart';
import 'package:cri_v6/features/store/controllers/txns_controller.dart';
import 'package:cri_v6/utils/constants/colors.dart';
import 'package:cri_v6/utils/constants/sizes.dart';
import 'package:cri_v6/utils/helpers/formatter.dart';
import 'package:cri_v6/utils/helpers/helper_functions.dart';
import 'package:cri_v6/utils/popups/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CIndividualTxnItem extends StatelessWidget {
  const CIndividualTxnItem({
    this.subtitle,
    this.title,
    required this.txnId,
    required this.isExpanded,
    this.boxColor,
    this.boxHeight,
    this.boxWidth,
    this.leadingWidget,
    this.subTitleWidget,
    this.titleWidget,

    super.key,
  });

  final bool isExpanded;
  final Color? boxColor;
  final double? boxHeight;
  final double? boxWidth;
  final int txnId;
  final String? subtitle, title;
  final Widget? leadingWidget, subTitleWidget, titleWidget;

  @override
  Widget build(BuildContext context) {
    final txnsController = Get.put(CTxnsController());
    final userController = Get.put(CUserController());
    final userCurrency = CHelperFunctions.formatCurrency(
      userController.user.value.currencyCode,
    );

    if (isExpanded) {
      Future.delayed(
        Duration.zero,
        () {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) {
              if (txnsController.transactionItems.isEmpty) {
                txnsController.fetchTxnItems(txnId);
              }
            },
          );
        },
      );
    }

    return SingleChildScrollView(
      child: Card(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            CSizes.borderRadiusLg,
          ),
          child: AnimatedContainer(
            color:
                boxColor ??
                CColors.rBrown.withValues(
                  alpha: .3,
                ),
            clipBehavior: Clip.antiAlias,
            curve: Curves.easeInOut,
            duration: const Duration(
              milliseconds: 200,
            ),
            height: boxHeight ?? CHelperFunctions.screenHeight() * .2,
            width: boxWidth ?? CHelperFunctions.screenWidth() * .8,

            child: Padding(
              padding: const EdgeInsets.only(
                left: 5.0,
                right: 5.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    flex: 1,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 8.0,
                      ),
                      leading: leadingWidget,
                      title:
                          titleWidget ??
                          Text(
                            title!,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                      subtitle:
                          subTitleWidget ??
                          Text(
                            subtitle ?? 'Details for item',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                    ),
                  ),

                  if (isExpanded)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CFormDivider(
                          dividerText: 'txn items',
                          dividerTxtFontSizeFactor: 1.2,
                        ),
                        Flexible(
                          child: ListView.builder(
                            itemCount: txnsController.transactionItems.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  left: 8.0,
                                  bottom: 4.0,
                                  top: 4.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CRoundedContainer(
                                      bgColor: CColors.transparent,
                                      width:
                                          CHelperFunctions.screenWidth() * .45,
                                      child: Text(
                                        txnsController
                                            .transactionItems[index]
                                            .productName
                                            .toUpperCase(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.labelMedium!.apply(),
                                      ),
                                    ),
                                    CRoundedContainer(
                                      bgColor: CColors.transparent,
                                      width:
                                          CHelperFunctions.screenWidth() * .35,
                                      child: Text(
                                        '${CFormatter.formatItemQtyDisplays(txnsController.transactionItems[index].quantity, txnsController.transactionItems[index].itemMetrics)} ${CFormatter.formatItemMetrics(txnsController.transactionItems[index].itemMetrics, txnsController.transactionItems[index].quantity)} @ $userCurrency.${txnsController.transactionItems[index].unitSellingPrice}',
                                      ),
                                    ),

                                    GestureDetector(
                                      onTap: () {
                                        CPopupSnackBar.customToast(
                                          forInternetConnectivityStatus: false,
                                          message: 'rada clean',
                                        );
                                      },
                                      child: Icon(
                                        Icons.arrow_forward_ios,
                                        size: CSizes.iconXs,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
