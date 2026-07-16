import 'package:cri_v6/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:cri_v6/common/widgets/login_signup/form_divider.dart';
import 'package:cri_v6/features/personalization/controllers/user_controller.dart';
import 'package:cri_v6/features/store/controllers/txns_controller.dart';
import 'package:cri_v6/utils/constants/colors.dart';
import 'package:cri_v6/utils/constants/sizes.dart';
import 'package:cri_v6/utils/helpers/formatter.dart';
import 'package:cri_v6/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CIndividualTxnItem extends StatelessWidget {
  CIndividualTxnItem({
    this.subtitle,
    this.title,
    required this.space,
    required this.isExpanded,
    required this.txnId,
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
  final String space;
  final String? subtitle, title;
  final Widget? leadingWidget, subTitleWidget, titleWidget;

  // 1. Create a single ScrollController
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = CHelperFunctions.isDarkMode(context);
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
              if (txnsController.transactionItems.isEmpty &&
                  (!txnsController.txnItemsLoading.value ||
                      !txnsController.isLoading.value)) {
                txnsController.fetchTxnItems(txnId);
              }
            },
          );
        },
      );
    }

    return SingleChildScrollView(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          CSizes.md,
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
          // padding: const EdgeInsets.only(
          //   bottom: 10.0,
          // ),
          width: boxWidth ?? CHelperFunctions.screenWidth() * .9,

          child: Flex(
            direction: Axis.vertical,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                flex: 1,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
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

              if (isExpanded && txnsController.transactionItems.isNotEmpty)
                Flexible(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: 5.0,
                      top: txnsController.transactionItems.length < 3
                          ? 20.0
                          : 10.0,
                    ),
                    child: CFormDivider(
                      dividerText: 'txn items',
                      dividerColor: CColors.rBrown.withValues(
                        alpha: 3.0,
                      ),
                      dividerTxtColor: CColors.rOrange,
                      dividerTxtFontSizeFactor: 1.03,
                      line1EndIndent: 10.0,
                      line1StartIndent: 40.0,
                      line2EndIndent: 30.0,
                      line2StartIndent: 10.0,
                    ),
                  ),
                ),

              if (isExpanded && txnsController.transactionItems.isNotEmpty)
                Flexible(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 5.0,
                    ),
                    child: Scrollbar(
                      // 2. Attach the controller to Scrollbar
                      controller: _scrollController,
                      radius: Radius.elliptical(
                        50,
                        50,
                      ),
                      thickness: 2.0,
                      thumbVisibility: true,
                      child: ListView.builder(
                        // 4. Attach the SAME controller to ListView
                        controller: _scrollController,
                        itemBuilder: (context, index) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //mainAxisSize: MainAxisSize.min,
                            children: [
                              CRoundedContainer(
                                bgColor: CColors.transparent,
                                padding: const EdgeInsets.all(
                                  0,
                                ),
                                width: CHelperFunctions.screenWidth() * .45,
                                child: Text(
                                  txnsController
                                      .transactionItems[index]
                                      .productName
                                      .toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      Theme.of(
                                        context,
                                      ).textTheme.labelSmall!.apply(
                                        fontSizeFactor: 1.1,
                                      ),
                                ),
                              ),
                              CRoundedContainer(
                                bgColor: CColors.transparent,
                                padding: const EdgeInsets.all(
                                  0,
                                ),
                                width: CHelperFunctions.screenWidth() * .27,
                                child: Text(
                                  '${CFormatter.formatItemQtyDisplays(txnsController.transactionItems[index].quantity, txnsController.transactionItems[index].itemMetrics)}${CFormatter.formatItemMetrics(txnsController.transactionItems[index].itemMetrics, txnsController.transactionItems[index].quantity)} $userCurrency.${txnsController.transactionItems[index].unitSellingPrice * txnsController.transactionItems[index].quantity}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      Theme.of(
                                        context,
                                      ).textTheme.labelSmall!.apply(
                                        fontSizeFactor: 1.1,
                                      ),
                                ),
                              ),

                              // GestureDetector(
                              //   onTap: () {
                              //     CPopupSnackBar.customToast(
                              //       forInternetConnectivityStatus: false,
                              //       message: 'rada clean',
                              //     );
                              //   },
                              //   child: Icon(
                              //     Icons.more_vert,
                              //     size: CSizes.iconXs,
                              //   ),
                              // ),
                              CRoundedContainer(
                                bgColor: CColors.transparent,
                                padding: const EdgeInsets.only(
                                  right: 5.0,
                                ),
                                child: GestureDetector(
                                  onTapDown: (TapDownDetails details) {
                                    showMenu<int>(
                                      context: context,
                                      position: RelativeRect.fromLTRB(
                                        details.globalPosition.dx,
                                        details.globalPosition.dy,
                                        details.globalPosition.dx,
                                        details.globalPosition.dy,
                                      ),
                                      items: [
                                        if (space != 'refunds' &&
                                            space != 'contact refunds')
                                          PopupMenuItem(
                                            onTap: () {
                                              txnsController
                                                  .refundItemActionModal(
                                                    context,
                                                    txnsController
                                                        .transactionItems[index],
                                                  );
                                            },
                                            value: 1,
                                            child: Text(
                                              'Refund',
                                            ),
                                          ),
                                        PopupMenuItem(
                                          value: 2,
                                          child: Text('Option 2'),
                                        ),
                                      ],
                                    );
                                  },
                                  child: Icon(
                                    Icons.more_vert,
                                    color: isDarkTheme
                                        ? CColors.darkGrey
                                        : CColors.rBrown,
                                    size: CSizes.iconSm,
                                  ),
                                ),
                              ),
                              // CRoundedContainer(
                              //   bgColor: CColors.transparent,
                              //   // padding: const EdgeInsets.only(
                              //   //   top: 5.0,
                              //   // ),
                              //   width: CHelperFunctions.screenWidth() * .26,
                              //   child: PopupMenuButton<int>(
                              //     borderRadius: BorderRadius.circular(
                              //       20,
                              //     ),
                              //     icon: const Icon(
                              //       Icons.more_vert,
                              //     ),
                              //     iconColor: CColors.rBrown,
                              //     iconSize: CSizes.iconSm,
                              //     itemBuilder: (context) {
                              //       return <PopupMenuEntry<int>>[
                              //         const PopupMenuItem(
                              //           child: Text(
                              //             'option 1',
                              //           ),
                              //         ),
                              //         const PopupMenuItem(
                              //           child: Text(
                              //             'option 2',
                              //           ),
                              //         ),
                              //       ];
                              //     },
                              //     onSelected: (int result) {
                              //       CPopupSnackBar.customToast(
                              //         forInternetConnectivityStatus: false,
                              //         message: 'option $result',
                              //       );
                              //     },
                              //     padding: const EdgeInsets.all(
                              //       0,
                              //     ),
                              //   ),
                              // ),
                            ],
                          );
                        },
                        itemCount: txnsController.transactionItems.length,
                        padding: const EdgeInsets.only(
                          left: 10.0,
                          right: 5.0,
                        ),
                        //physics: AlwaysScrollableScrollPhysics(),
                        shrinkWrap: true,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
