import 'package:cri_v6/common/widgets/loaders/animated_loader.dart';
import 'package:cri_v6/common/widgets/products/product_cards/p_card_vertical.dart';
import 'package:cri_v6/features/personalization/controllers/user_controller.dart';
import 'package:cri_v6/features/store/controllers/inv_controller.dart';
import 'package:cri_v6/features/store/controllers/search_bar_controller.dart';
import 'package:cri_v6/features/store/controllers/sync_controller.dart';
import 'package:cri_v6/features/store/models/inv_model.dart';
import 'package:cri_v6/features/store/screens/search/widgets/no_results_screen.dart';
import 'package:cri_v6/features/store/screens/store_items_tings/inventory/widgets/inv_dialog.dart';
import 'package:cri_v6/utils/computations/date_time_computations.dart';
import 'package:cri_v6/utils/constants/colors.dart';
import 'package:cri_v6/utils/constants/img_strings.dart';
import 'package:cri_v6/utils/constants/sizes.dart';
import 'package:cri_v6/utils/helpers/formatter.dart';
import 'package:cri_v6/utils/helpers/helper_functions.dart';
import 'package:cri_v6/utils/popups/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CInvGridviewScreen extends StatelessWidget {
  const CInvGridviewScreen({
    required this.screen,
    this.contactName = '',
    this.contactEmail = '',
    this.contactPhone = '',
    this.mainAxisExtent,
    super.key,
  });

  final double? mainAxisExtent;
  final String screen;
  final String? contactName, contactEmail, contactPhone;

  @override
  Widget build(BuildContext context) {
    AddUpdateItemDialog dialog = AddUpdateItemDialog();

    final isDarkTheme = CHelperFunctions.isDarkMode(context);
    final invController = Get.put(CInventoryController());
    final searchController = Get.put(CSearchBarController());
    final syncController = Get.put(CSyncController());
    final userController = Get.put(CUserController());

    if (screen == 'store') {
      invController.fetchUserInventoryItems();
    }

    return Obx(
      () {
        var demInventoryItems = [];

        if (invController.inventoryItems.isEmpty &&
            invController.foundInventoryItems.isEmpty) {
          demInventoryItems = [];
        } else {
          switch (screen) {
            case 'store':
              demInventoryItems.assignAll(
                searchController.showSearchField.value &&
                        searchController.txtSearchField.text != '' &&
                        !invController.isLoading.value
                    ? invController.foundInventoryItems
                    : invController.inventoryItems,
              );
              break;
            case 'contact supplies':
              demInventoryItems.assignAll(
                invController.inventoryItems.where(
                  (contactSupply) {
                    return contactSupply.supplierName
                            .trim()
                            .toLowerCase()
                            .contains(contactName!.trim().toLowerCase()) &&
                        (contactSupply.supplierContacts
                                .trim()
                                .toLowerCase()
                                .contains(contactEmail!.trim().toLowerCase()) ||
                            contactSupply.supplierContacts
                                .trim()
                                .toLowerCase()
                                .contains(contactPhone!.trim().toLowerCase()));
                  },
                ),
              );
              break;
            default:
              demInventoryItems.assignAll(
                invController.inventoryItems,
              );
              break;
          }

          if (demInventoryItems.isEmpty) {
            return const NoSearchResultsScreen();
          }
        }

        /// -- empty data widget --
        final noDataWidget = SizedBox(
          height: 200.0,
          child: CAnimatedLoaderWidget(
            actionBtnWidth: 180.0,
            actionBtnText: 'Let\'s fill it!',
            animation: CImages.noDataLottie,
            lottieAssetWidth: CHelperFunctions.screenWidth() * 0.42,
            onActionBtnPressed: () {
              invController.addInvItemDialogAction(false);
            },
            showActionBtn: true,
            text: 'Whoops! Store is EMPTY!',
          ),
        );

        if (demInventoryItems.isEmpty && !invController.isLoading.value) {
          return noDataWidget;
        }

        return ListView(
          padding: const EdgeInsets.only(
            left: 5.0,
            right: 5.0,
            top: 10.0,
          ),
          shrinkWrap: true,
          children: [
            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: CSizes.gridViewSpacing / 2,
                crossAxisSpacing: CSizes.gridViewSpacing / 2,
                mainAxisExtent: CHelperFunctions.screenHeight() * .2965,
              ),
              itemCount: demInventoryItems.length,
              itemBuilder: (context, index) {
                return CProductCardVertical(
                  avatarColor: CHelperFunctions.generateInvItemsDisplayColor(
                    isDarkTheme ? CColors.white : CColors.rBrown,

                    demInventoryItems[index].quantity,
                    demInventoryItems[index].lowStockNotifierLimit,
                    demInventoryItems[index].expiryDate,
                  ),
                  bp: demInventoryItems[index].buyingPrice.toStringAsFixed(2),

                  containerHeight: CHelperFunctions.screenHeight() * .2,
                  deleteAction: syncController.processingSync.value
                      ? null
                      : () {
                          CInventoryModel itemIndex = demInventoryItems[index];

                          invController.deleteInventoryWarningPopup(itemIndex);
                        },
                  expiryDate: demInventoryItems[index].expiryDate != ''
                      ? CFormatter.formatTimeRangeFromNow(
                          demInventoryItems[index].expiryDate.replaceAll(
                            '@ ',
                            '',
                          ),
                        )
                      : 'N/A',

                  expiryColor: demInventoryItems[index].expiryDate != ''
                      ? CDateTimeComputations.timeRangeFromNow(
                                  demInventoryItems[index].expiryDate
                                      .replaceAll('@ ', ''),
                                ) <=
                                0
                            ? CColors.error
                            : CDateTimeComputations.timeRangeFromNow(
                                    demInventoryItems[index].expiryDate
                                        .replaceAll('@ ', ''),
                                  ) <=
                                  3
                            ? CColors.warning
                            : CColors.darkGrey
                      : CColors.darkGrey,
                  favIconColor: demInventoryItems[index].markedAsFavorite == 1
                      ? Colors.red
                      : CColors.white,
                  itemName: demInventoryItems[index].name,
                  pCode: demInventoryItems[index].pCode,
                  pId: demInventoryItems[index].productId,
                  isSynced: demInventoryItems[index].isSynced.toString(),
                  itemAvatar: demInventoryItems[index].name[0],
                  itemMetrics: demInventoryItems[index].calibration,
                  lastModified: demInventoryItems[index].lastModified,
                  lowStockNotifierLimit:
                      demInventoryItems[index].lowStockNotifierLimit,
                  onAvatarIconTap: syncController.processingSync.value
                      ? null
                      : () {
                          invController.resetInvFields().then((_) {
                            invController.itemExists.value = true;
                            invController.txtSupplierName.text =
                                demInventoryItems[index].supplierName;
                            invController.txtSupplierContacts.text =
                                demInventoryItems[index].supplierContacts;

                            invController.includeSupplierDetails.value =
                                demInventoryItems[index].supplierName != '' ||
                                demInventoryItems[index].supplierContacts != '';
                            invController.includeExpiryDate.value =
                                demInventoryItems[index].expiryDate != '';
                            showDialog(
                              context: Get.overlayContext!,
                              useRootNavigator: true,
                              builder: (BuildContext context) {
                                invController.currentItemId.value =
                                    demInventoryItems[index].productId!;

                                return dialog.buildDialog(
                                  context,
                                  CInventoryModel.withID(
                                    invController.currentItemId.value,
                                    userController.user.value.id,
                                    userController.user.value.email,
                                    userController.user.value.fullName,
                                    demInventoryItems[index].pCode,
                                    demInventoryItems[index].name,
                                    demInventoryItems[index].markedAsFavorite,
                                    demInventoryItems[index].calibration,
                                    demInventoryItems[index].quantity,
                                    demInventoryItems[index].qtySold,
                                    demInventoryItems[index].qtyRefunded,
                                    demInventoryItems[index].buyingPrice,
                                    demInventoryItems[index].unitBp,
                                    demInventoryItems[index].unitSellingPrice,
                                    demInventoryItems[index]
                                        .lowStockNotifierLimit,
                                    demInventoryItems[index].supplierName,
                                    demInventoryItems[index].supplierContacts,
                                    demInventoryItems[index].dateAdded,
                                    demInventoryItems[index].lastModified,
                                    demInventoryItems[index].expiryDate,
                                    demInventoryItems[index].isSynced,
                                    demInventoryItems[index].syncAction,
                                  ),
                                  false,
                                  false,
                                );
                              },
                            );
                          });
                        },
                  onDoubleTapAction: () {
                    Get.toNamed(
                      '/inventory/item_details/',
                      arguments: demInventoryItems[index].productId,
                    );
                  },
                  onFavoriteIconTap: () {
                    invController.toggleFavoriteStatus(
                      demInventoryItems[index],
                    );
                  },
                  onTapAction: () {
                    CPopupSnackBar.customToast(
                      message: 'double tap on item to see details!!',
                      forInternetConnectivityStatus: false,
                    );
                  },
                  qtyAvailable: CFormatter.formatItemQtyDisplays(
                    demInventoryItems[index].quantity,
                    demInventoryItems[index].calibration,
                  ),
                  qtyRefunded: CFormatter.formatItemQtyDisplays(
                    demInventoryItems[index].qtyRefunded,
                    demInventoryItems[index].calibration,
                  ),
                  qtySold: CFormatter.formatItemQtyDisplays(
                    demInventoryItems[index].qtySold,
                    demInventoryItems[index].calibration,
                  ),
                  syncAction: demInventoryItems[index].syncAction,
                  stockValue:
                      (demInventoryItems[index].unitBp *
                              demInventoryItems[index].quantity)
                          .toStringAsFixed(2),

                  titleColor: CHelperFunctions.generateInvItemsDisplayColor(
                    isDarkTheme ? CColors.white : CColors.rBrown,
                    demInventoryItems[index].quantity,
                    demInventoryItems[index].lowStockNotifierLimit,
                    demInventoryItems[index].expiryDate,
                  ),
                  usp: demInventoryItems[index].unitSellingPrice.toString(),
                );
              },
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
            ),
          ],
        );
      },
    );
  }
}
