import 'package:cri_v6/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:cri_v6/common/widgets/login_signup/form_divider.dart';
import 'package:cri_v6/common/widgets/shimmers/vert_items_shimmer.dart';
import 'package:cri_v6/features/personalization/controllers/contacts_controller.dart';
import 'package:cri_v6/features/personalization/controllers/user_controller.dart';
import 'package:cri_v6/features/personalization/models/contacts_model.dart';
import 'package:cri_v6/features/personalization/screens/no_data/no_data_screen.dart';
import 'package:cri_v6/features/store/controllers/search_bar_controller.dart';
import 'package:cri_v6/features/store/controllers/sync_controller.dart';
import 'package:cri_v6/features/store/controllers/txns_controller.dart';
import 'package:cri_v6/features/store/screens/search/widgets/no_results_screen.dart';
import 'package:cri_v6/features/store/screens/store_items_tings/widgets/individual_txn_item.dart';
import 'package:cri_v6/utils/constants/colors.dart';
import 'package:cri_v6/utils/constants/img_strings.dart';
import 'package:cri_v6/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CTxnItemsListView extends StatefulWidget {
  const CTxnItemsListView({
    super.key,
    this.contactId,
    required this.forContactScreen,
    required this.space,
  });

  final int? contactId;
  final bool forContactScreen;
  final String space;

  @override
  State<CTxnItemsListView> createState() => _CTxnItemsListViewState();
}

class _CTxnItemsListViewState extends State<CTxnItemsListView> {
  int? _expandedIndex; // Stores the index of the currently expanded item

  @override
  Widget build(BuildContext context) {
    /// -- variables --
    final contactsController = Get.put(CContactsController());
    final isDarkTheme = CHelperFunctions.isDarkMode(context);
    final searchController = Get.put(CSearchBarController());
    final syncController = Get.put(CSyncController());
    final txnsController = Get.put(CTxnsController());
    final userController = Get.put(CUserController());
    final userCurrency = CHelperFunctions.formatCurrency(
      userController.user.value.currencyCode,
    );

    return Obx(
      () {
        var demItems = [];

        CContactsModel contactItem = CContactsModel.empty();

        if (widget.forContactScreen) {
          contactItem = contactsController.myContacts.firstWhere(
            (element) => element.contactId == Get.arguments,
          );
        }

        switch (widget.space) {
          case 'invoices':
            demItems.assignAll(
              searchController.showSearchField.value &&
                      searchController.txtSearchField.text != '' &&
                      !txnsController.isLoading.value
                  ? txnsController.foundInvoices
                  : txnsController.invoices,
            );
            break;
          case 'contact invoices':
            demItems.assignAll(
              txnsController.invoices.where(
                (contactInvoice) {
                  return contactInvoice.customerName.toLowerCase().contains(
                        contactItem.contactName.toLowerCase(),
                      ) &&
                      (contactInvoice.customerContacts.toLowerCase().contains(
                            contactItem.contactPhone.toLowerCase(),
                          ) ||
                          contactInvoice.customerContacts
                              .toLowerCase()
                              .contains(
                                contactItem.contactEmail.toLowerCase(),
                              ));
                },
              ),
            );
            break;
          case 'receipts':
            demItems.assignAll(
              searchController.showSearchField.value &&
                      searchController.txtSearchField.text != '' &&
                      !txnsController.isLoading.value
                  ? txnsController.foundReceipts
                  : txnsController.receipts,
            );
            break;
          case 'contact receipts':
            demItems.assignAll(
              txnsController.receipts.where(
                (contactReceipt) {
                  return contactReceipt.customerName.toLowerCase().contains(
                        contactItem.contactName.toLowerCase(),
                      ) &&
                      (contactReceipt.customerContacts.toLowerCase().contains(
                            contactItem.contactPhone.toLowerCase(),
                          ) ||
                          contactReceipt.customerContacts
                              .toLowerCase()
                              .contains(
                                contactItem.contactEmail.toLowerCase(),
                              ));
                },
              ),
            );
            break;
          case 'sales':
            demItems.assignAll(
              searchController.showSearchField.value &&
                      searchController.txtSearchField.text != '' &&
                      !txnsController.isLoading.value
                  ? txnsController.foundSales
                  : txnsController.sales,
            );
            break;

          case 'refunds':
            demItems.assignAll(
              searchController.showSearchField.value &&
                      searchController.txtSearchField.text != '' &&
                      !txnsController.isLoading.value
                  ? txnsController.foundRefunds
                  : txnsController.refunds,
            );
            break;

          case 'contact refunds':
            demItems.assignAll(
              txnsController.refunds.where(
                (contactRefund) {
                  return contactRefund.customerName.toLowerCase().contains(
                        contactItem.contactName.toLowerCase(),
                      ) &&
                      (contactRefund.customerContacts.toLowerCase().contains(
                            contactItem.contactPhone.toLowerCase(),
                          ) ||
                          contactRefund.customerContacts.toLowerCase().contains(
                            contactItem.contactEmail.toLowerCase(),
                          ));
                },
              ),
            );
            break;
          default:
            demItems.clear();

            break;
        }

        if (searchController.showSearchField.value &&
            !txnsController.isLoading.value &&
            demItems.isEmpty) {
          return const NoSearchResultsScreen();
        }

        if (!searchController.showSearchField.value && demItems.isEmpty) {
          return Center(
            child: NoDataScreen(
              lottieImage: CImages.noDataLottie,
              txt: '${widget.space} will be displayed here...',
            ),
          );
        }

        if (syncController.processingSync.value) {
          return const CVerticalProductShimmer(
            itemCount: 5,
          );
        }

        return ListView.separated(
          itemBuilder: (context, index) {
            final bool isExpanded = _expandedIndex == index;

            return GestureDetector(
              onTap: () {
                setState(
                  () {
                    // -- if tapping the already expanded index, collapse it; otherwise expand this one and collapse all the others --
                    _expandedIndex = isExpanded ? null : index;
                    if (!isExpanded) {
                      txnsController.transactionItems.clear();
                    }
                  },
                );
              },
              child: CIndividualTxnItem(
                boxColor: isDarkTheme && isExpanded
                    ? CColors.rBrown.withValues(
                        alpha: .2,
                      )
                    : isDarkTheme && !isExpanded
                    ? CColors.rBrown.withValues(
                        alpha: .4,
                      )
                    : isExpanded
                    ? CColors.lightGrey.withValues(
                        alpha: .4,
                      )
                    : CColors.lightGrey,
                boxHeight:
                    isExpanded &&
                        txnsController.transactionItems.isNotEmpty &&
                        txnsController.transactionItems.length <= 3
                    ? 210.0
                    : isExpanded &&
                          txnsController.transactionItems.isNotEmpty &&
                          txnsController.transactionItems.length > 3
                    ? (txnsController.transactionItems.length * 43) + 43
                    : 120.0,
                isExpanded: isExpanded,
                space: widget.space,
                subTitleWidget: Flex(
                  direction: Axis.vertical,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 5.0,
                  children: [
                    Flexible(
                      flex: isExpanded ? 2 : 1,
                      child: CRoundedContainer(
                        bgColor: CColors.transparent,
                        //height: CHelperFunctions.screenHeight() * .25,
                        padding: const EdgeInsets.only(
                          top: 5.0,
                          bottom: 3.0,
                        ),
                        width: CHelperFunctions.screenWidth() * .95,
                        //showBorder: true,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'sold to:',
                              style:
                                  Theme.of(
                                    context,
                                  ).textTheme.labelMedium!.apply(
                                    color: CColors.darkGrey,
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                            Wrap(
                              alignment: WrapAlignment.end,
                              direction: Axis.vertical,
                              spacing: 5.0,
                              children: [
                                Text(
                                  demItems[index].customerName == ''
                                      ? 'name: N/A '
                                      : 'name: ${demItems[index].customerName}; ',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      Theme.of(
                                        context,
                                      ).textTheme.labelMedium!.apply(
                                        color: CColors.darkGrey,
                                        fontStyle: FontStyle.italic,
                                      ),
                                  textAlign: TextAlign.right,
                                ),
                                Text(
                                  demItems[index].customerContacts == ''
                                      ? 'contacts: N/A '
                                      : 'contacts: ${demItems[index].customerContacts} ',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      Theme.of(
                                        context,
                                      ).textTheme.labelMedium!.apply(
                                        color: CColors.darkGrey,
                                        fontStyle: FontStyle.italic,
                                      ),
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Flexible(
                      flex: isExpanded ? 2 : 1,
                      child:
                          widget.space == 'refunds' ||
                              widget.space == 'contact refunds'
                          ? Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    bottom: 5.0,
                                    top: 1.0,
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
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      demItems[index].productName.toUpperCase(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelMedium!.apply(),
                                    ),
                                    Text(
                                      'Amt: $userCurrency.${demItems[index].unitSellingPrice * demItems[index].qtyRefunded}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelMedium!.apply(),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Text(
                                    'discount:',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelMedium!.apply(),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '$userCurrency.${demItems[index].discount}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelMedium!.apply(),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
                titleWidget: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '#${demItems[index].txnId}',
                      style: Theme.of(
                        context,
                      ).textTheme.labelMedium!.apply(),
                    ),
                    Text(
                      widget.space == 'refunds'
                          ? 'Amt: $userCurrency.${demItems[index].qtyRefunded * demItems[index].unitSellingPrice}'
                          : 'Amt: $userCurrency.${demItems[index].totalAmount}',
                      style: Theme.of(
                        context,
                      ).textTheme.labelMedium!.apply(),
                    ),
                  ],
                ),
                //title: '${demItems[index].txnId}',
                txnId: demItems[index].txnId,
              ),
            );
          },
          itemCount: demItems.length,
          padding: const EdgeInsets.only(
            left: 10.0,
            right: 10.0,
            top: 5.0,
          ),
          separatorBuilder: (context, index) {
            return const SizedBox(
              height: 3.0,
            );
          },
          shrinkWrap: true,
        );
      },
    );
  }
}
