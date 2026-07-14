import 'package:cri_v6/common/widgets/anime/animated_digit_widget.dart';
import 'package:cri_v6/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:cri_v6/common/widgets/list_tiles/menu_tile.dart';
import 'package:cri_v6/common/widgets/txt_widgets/c_section_headings.dart';
import 'package:cri_v6/features/personalization/controllers/user_controller.dart';
import 'package:cri_v6/features/store/controllers/inv_controller.dart';
import 'package:cri_v6/features/store/controllers/txns_controller.dart';
import 'package:cri_v6/features/store/models/inv_model.dart';
import 'package:cri_v6/features/store/screens/store_items_tings/inventory/inventory_details/widgets/add_to_cart_bottom_nav_bar.dart';
import 'package:cri_v6/features/store/screens/store_items_tings/inventory/inventory_details/widgets/cards/kpi_display_card.dart';
import 'package:cri_v6/features/store/screens/store_items_tings/inventory/widgets/inv_dialog.dart';
import 'package:cri_v6/utils/constants/colors.dart';
import 'package:cri_v6/utils/constants/sizes.dart';
import 'package:cri_v6/utils/helpers/formatter.dart';
import 'package:cri_v6/utils/helpers/helper_functions.dart';
import 'package:cri_v6/utils/popups/snackbars.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CInvDetails extends StatelessWidget {
  const CInvDetails({super.key});

  /// TODO: include txn status (invoiced, complete)

  @override
  Widget build(BuildContext context) {
    AddUpdateItemDialog dialog = AddUpdateItemDialog();
    final invController = Get.put(CInventoryController());
    final isDarkTheme = CHelperFunctions.isDarkMode(context);
    final txnsController = Get.put(CTxnsController());
    final userController = Get.put(CUserController());

    return Container(
      color: isDarkTheme ? CColors.transparent : CColors.white,
      child: Obx(() {
        final currency = CHelperFunctions.formatCurrency(
          userController.user.value.currencyCode,
        );
        var itemId = Get.arguments;

        var invItem = invController.inventoryItems.firstWhere(
          (item) => item.productId == itemId,
        );

        txnsController.computeKPIs(invItem);

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: true,
            elevation: 1.0,
            shadowColor: CColors.rBrown.withValues(alpha: 0.1),
            iconTheme: IconThemeData(
              color: isDarkTheme ? CColors.white : CColors.rBrown,
            ),
            title: SelectableText(
              '#${invItem.productId}',
              style: Theme.of(context).textTheme.labelMedium!.apply(
                color: isDarkTheme ? CColors.grey : CColors.rBrown,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: Icon(
                  Iconsax.notification,
                  color: isDarkTheme ? CColors.white : CColors.rBrown,
                ),
              ),
            ],
          ),
          backgroundColor: CColors.rBrown.withValues(
            alpha: 0.2,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: CSizes.spaceBtnItems,
                ),
                CircleAvatar(
                  backgroundColor:
                      CHelperFunctions.generateInvItemsDisplayColor(
                        Colors.brown[300],
                        invItem.quantity,
                        invItem.lowStockNotifierLimit,
                        invItem.expiryDate,
                      ),
                  radius: 25.0,
                  child: Text(
                    invItem.name[0].toUpperCase(),
                    style:
                        Theme.of(
                          context,
                        ).textTheme.labelLarge!.apply(
                          color: CColors.white,
                          fontSizeFactor: 1.4,
                        ),
                  ),
                ),
                const SizedBox(
                  height: CSizes.spaceBtnItems,
                ),

                Text(
                  invItem.name.toUpperCase(),
                  style: Theme.of(context).textTheme.bodyMedium!.apply(
                    color: isDarkTheme ? CColors.grey : CColors.rBrown,
                    fontSizeDelta: 2.0,
                    fontWeightDelta: 2,
                  ),
                ),
                Text(
                  'Modified: ${invItem.lastModified.replaceAll(' @', '')}',
                  style: Theme.of(context).textTheme.headlineSmall!.apply(
                    color: CColors.darkGrey,
                    fontSizeFactor: 0.6,
                  ),
                ),

                const SizedBox(
                  height: CSizes.spaceBtnItems,
                ),

                /// -- low-stock, out of stock notification --
                Visibility(
                  visible: invItem.quantity <= invItem.lowStockNotifierLimit,
                  child: CRoundedContainer(
                    bgColor: Colors.redAccent,
                    borderRadius: CSizes.borderRadiusLg * 1.5,
                    height: 50.0,
                    padding: const EdgeInsets.only(
                      left: 15.0,
                      right: 15.0,
                    ),
                    width: CHelperFunctions.screenWidth() * .65,

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Icon(
                          invItem.quantity == 0
                              ? Iconsax.danger
                              : Icons.alarm_on,
                          color: CColors.white,
                          size: CSizes.iconSm,
                        ),
                        const SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          invItem.quantity == 0
                              ? 'This item is out of stock!!'
                              : 'only ${CFormatter.formatItemQtyDisplays(invItem.quantity, invItem.calibration)} ${CFormatter.formatItemMetrics(invItem.calibration, invItem.quantity)} stocked!!',
                          style: Theme.of(context).textTheme.bodyMedium!.apply(
                            color: CColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /// -- expiry notification display --
                if (invItem.expiryDate != '')
                  Visibility(
                    visible:
                        invItem.expiryDate != '' &&
                        CFormatter.computeTimeRangeFromNow(
                              invItem.expiryDate.replaceAll(
                                '@ ',
                                '',
                              ),
                            ) <=
                            3,
                    child: CRoundedContainer(
                      bgColor:
                          CFormatter.computeTimeRangeFromNow(
                                invItem.expiryDate.replaceAll(
                                  '@ ',
                                  '',
                                ),
                              ) <=
                              3
                          ? CColors.warning
                          : Colors.redAccent,
                      borderRadius: CSizes.borderRadiusLg * 1.5,
                      height: 50.0,
                      padding: const EdgeInsets.only(
                        left: 15.0,
                        right: 15.0,
                      ),
                      width: CHelperFunctions.screenWidth() * .65,

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          Icon(
                            CFormatter.computeTimeRangeFromNow(
                                      invItem.expiryDate.replaceAll(
                                        '@ ',
                                        '',
                                      ),
                                    ) <=
                                    3
                                ? Iconsax.danger
                                : Icons.alarm_on,
                            color: CColors.white,
                            size: CSizes.iconSm,
                          ),
                          const SizedBox(
                            width: 10.0,
                          ),
                          Text(
                            CFormatter.computeTimeRangeFromNow(
                                      invItem.expiryDate.replaceAll('@ ', ''),
                                    ) <=
                                    0
                                ? '${invItem.name.toUpperCase()} is expired!!'
                                : '${invItem.name.toUpperCase()} expires ${CFormatter.formatTimeRangeFromNow(invItem.expiryDate.replaceAll('@ ', ''))}',
                            style: Theme.of(context).textTheme.bodyMedium!
                                .apply(
                                  color: CColors.white,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),

                /// -- metrics measurement for retail optimization --
                Padding(
                  padding: const EdgeInsets.only(
                    left: 10.0,
                    top: 10.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CSectionHeading(
                        showActionBtn: false,
                        title: 'Financial KPIs',
                        btnTitle: '',
                        editFontSize: false,
                      ),
                      const SizedBox(
                        height: CSizes.spaceBtnSections / 2.0,
                      ),

                      /// -- total units sold --
                      CKPIDisplayCard(
                        animeDigit: txnsController.totalAmtSold.value,
                        anotherTitleWidget: CAnimatedDigitWidget(
                          fractionDigits: 0,
                          prefix: ' (',
                          suffix:
                              ' ${CFormatter.formatItemMetrics(invItem.calibration, txnsController.numberOfUnitsSold.value)})',
                          txtStyle: Theme.of(context).textTheme.titleMedium!
                              .apply(
                                color: CColors.rOrange,
                                fontWeightDelta: 2,
                              ),
                          value: txnsController.numberOfUnitsSold.value,
                        ),
                        fractionDigits: 0,
                        prefixLabel: currency,
                      ),

                      /// -- gross profit and gross profit percentage --
                      CKPIDisplayCard(
                        animeDigit: txnsController.grossProfit.value,
                        anotherTitleWidget: CAnimatedDigitWidget(
                          prefix: ' (',
                          suffix: '%)',
                          txtStyle: Theme.of(context).textTheme.titleMedium!
                              .apply(
                                color: CColors.rOrange,
                                fontWeightDelta: 2,
                              ),
                          value: txnsController.grossProfitPercentage.value,
                        ),
                        leadingWidget: Icon(
                          Iconsax.money_recive,
                          color: CColors.rBrown,
                        ),
                        prefixLabel: currency,
                        subTitle: 'Gross Profit',
                      ),

                      /// -- Inventory Turnover Ratio --
                      CKPIDisplayCard(
                        animeDigit: txnsController.inventoryTurn.value,
                        leadingWidget: Icon(
                          Icons.aspect_ratio,
                          color: CColors.rBrown,
                        ),
                        prefixLabel: '',
                        subTitle: 'Inventory Turnover Ratio',
                      ),

                      /// -- inventory turn days --
                      CKPIDisplayCard(
                        animeDigit: txnsController.inventoryTurnDays.value,
                        leadingWidget: Icon(
                          Iconsax.calendar,
                          color: CColors.rBrown,
                        ),
                        prefixLabel: 'days',

                        subTitle: 'Inventory Turn Days',
                      ),

                      /// -- Gross Margin Return On Inventory Investment (GMROI) --
                      CKPIDisplayCard(
                        animeDigit: txnsController.gmroi.value,
                        prefixLabel: currency,
                        subTitle:
                            'Gross Margin Return On Inventory Investment (GMROI)',
                      ),

                      /// -- return on investment --
                      CKPIDisplayCard(
                        animeDigit: txnsController.roi.value,
                        leadingWidget: Icon(
                          Iconsax.trend_up,
                          color: CColors.rBrown,
                        ),
                        prefixLabel: '%',
                        subTitle: 'Return On Inventory Investment (ROI)',
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: CSizes.spaceBtnItems,
                ),

                Padding(
                  padding: const EdgeInsets.only(
                    bottom: CSizes.defaultSpace / 3,
                    left: CSizes.defaultSpace / 3,
                    right: CSizes.defaultSpace / 3,
                    top: CSizes.defaultSpace / 1.5,
                  ),
                  child: Column(
                    children: [
                      const CSectionHeading(
                        showActionBtn: false,
                        title: 'Inventory details',
                        btnTitle: '',
                        editFontSize: false,
                      ),
                      CMenuTile(
                        icon: Iconsax.user,
                        title: invItem.userName,
                        // subTitle: invItem.userEmail,
                        subTitle: 'added by',
                        onTap: () {},
                      ),

                      CMenuTile(
                        icon: Iconsax.hashtag5,
                        title: invItem.productId.toString(),
                        subTitle: 'product/item id',
                        onTap: () {},
                      ),

                      CMenuTile(
                        icon: Iconsax.barcode,
                        title: invItem.pCode,
                        subTitle: 'sku/code',
                        onTap: () {},
                      ),

                      CMenuTile(
                        icon: Iconsax.calendar,
                        title: invItem.dateAdded,
                        subTitle: 'Date added',
                        onTap: () {},
                      ),

                      // TODO: ability to update expiry date
                      CMenuTile(
                        icon: Iconsax.calendar,
                        title: invItem.expiryDate != ''
                            ? '${CFormatter.formatTimeRangeFromNow(invItem.expiryDate.replaceAll('@ ', ''))} (${invItem.expiryDate})'
                            : 'N/A',
                        titleColor:
                            CHelperFunctions.generateInvItemsDisplayColor(
                              CColors.rBrown,
                              invItem.quantity,
                              invItem.lowStockNotifierLimit,
                              invItem.expiryDate,
                            ),
                        subTitle: 'Expiry date/Shelflife',
                        onTap: () {},
                      ),

                      CMenuTile(
                        icon: Iconsax.shopping_cart,
                        title:
                            '${invItem.calibration == 'units' ? invItem.quantity.toInt() : invItem.quantity} (${invItem.calibration == 'units' ? invItem.qtyRefunded.toInt() : invItem.qtyRefunded} ${CFormatter.formatItemMetrics(invItem.calibration, invItem.qtyRefunded)} refunded)',
                        subTitle: 'in stock',
                        onTap: () {},
                      ),

                      // CMenuTile(
                      //   icon: Iconsax.shopping_cart,
                      //   title: '${(invItem.qtyRefunded)}',
                      //   subTitle: 'Qty/units refunded',
                      //   onTap: () {},
                      // ),
                      CMenuTile(
                        icon: Iconsax.bitcoin_card,
                        //title: '',
                        title: '$currency.${(invItem.buyingPrice)}',
                        subTitle: 'buying price',
                        onTap: () {
                          //Get.to(() => const UserAddressesScreen());
                        },
                      ),

                      CMenuTile(
                        icon: Iconsax.card_pos,
                        //title: '',
                        title: '$currency. ${(invItem.unitSellingPrice)}',
                        subTitle: 'unit selling price',
                        onTap: () {
                          //Get.to(() => const OrdersScreen());
                        },
                      ),

                      CMenuTile(
                        icon: Iconsax.card_pos,
                        //title: '',
                        title: '$currency.${(invItem.unitBp)}',
                        subTitle: '~ unit buying price',
                        onTap: () {
                          //Get.to(() => const OrdersScreen());
                        },
                      ),

                      CMenuTile(
                        icon: Iconsax.calendar,
                        title: invItem.lastModified,
                        subTitle: 'last modified',
                        onTap: () {},
                      ),

                      CMenuTile(
                        icon: Icons.contact_mail,
                        onTap: () {
                          if (kDebugMode) {
                            CPopupSnackBar.customToast(
                              message: 'tap iko sawa',
                              forInternetConnectivityStatus: false,
                            );
                          }
                        },
                        subTitle: 'supplier name, contacts',
                        title: invItem.supplierName.isNotEmpty
                            ? '${invItem.supplierName} (${invItem.supplierContacts})'
                            : 'N/A',
                        trailing: Icon(
                          Iconsax.pen_add,
                          color: CColors.rBrown,
                        ),
                      ),
                      CMenuTile(
                        icon: Iconsax.notification,
                        title: 'notifications',
                        subTitle: 'customize notification messages',
                        onTap: () {},
                      ),

                      const SizedBox(
                        height: CSizes.spaceBtnSections,
                      ),

                      // -- app settings
                      const CSectionHeading(
                        showActionBtn: false,
                        title: 'app settings',
                        btnTitle: '',
                        editFontSize: false,
                      ),
                      const SizedBox(height: CSizes.spaceBtnItems),
                      CMenuTile(
                        icon: Iconsax.document_upload,
                        title: 'upload data',
                        subTitle: 'upload data to your cloud firebase',
                        trailing: IconButton(
                          onPressed: () {},
                          icon: const Icon(Iconsax.arrow_right),
                        ),
                        onTap: () {},
                      ),
                      CMenuTile(
                        icon: Iconsax.location,
                        title: 'geolocation',
                        subTitle: 'set recommendation based on location',
                        trailing: Switch(
                          value: true,
                          activeThumbColor: CColors.rBrown,
                          onChanged: (value) {},
                        ),
                      ),
                      CMenuTile(
                        icon: Iconsax.security_user,
                        title: 'safe mode',
                        subTitle:
                            'search result is safe for people of all ages',
                        trailing: Switch(
                          value: false,
                          activeThumbColor: CColors.rBrown,
                          onChanged: (value) {},
                        ),
                      ),

                      const Divider(),
                      const SizedBox(height: CSizes.spaceBtnItems),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Obx(() {
            if (!invController.isLoading.value &&
                invController.inventoryItems.isEmpty) {
              invController.fetchUserInventoryItems();
            }
            var thisItem = invController.inventoryItems.firstWhere(
              (item) => item.productId == itemId,
            );
            return CAddToCartBottomNavBar(
              inventoryItem: thisItem,
            );
          }),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                onPressed: () {
                  invController.itemExists.value = true;

                  showDialog(
                    context: context,
                    useRootNavigator: false,
                    builder: (BuildContext context) {
                      invController.currentItemId.value = itemId;
                      invController.txtSupplierName.text = invItem.supplierName;
                      invController.txtSupplierContacts.text =
                          invItem.supplierContacts;

                      invController.includeSupplierDetails.value =
                          invItem.supplierName != '' ||
                          invItem.supplierContacts != '';
                      invController.includeExpiryDate.value =
                          invItem.expiryDate != '';

                      return dialog.buildDialog(
                        context,
                        CInventoryModel.withID(
                          itemId,
                          userController.user.value.id,
                          userController.user.value.email,
                          userController.user.value.fullName,
                          invItem.pCode,
                          invItem.name,
                          invItem.markedAsFavorite,
                          invItem.calibration,
                          invItem.quantity,
                          invItem.qtySold,
                          invItem.qtyRefunded,
                          invItem.buyingPrice,
                          invItem.unitBp,
                          invItem.unitSellingPrice,
                          invItem.lowStockNotifierLimit,
                          invItem.supplierName,
                          invItem.supplierContacts,
                          invItem.dateAdded,
                          invItem.lastModified,
                          invItem.expiryDate,
                          invItem.isSynced,
                          invItem.syncAction,
                        ),
                        false,
                        false,
                      );
                    },
                  );
                  invController.txtId.text = (invItem.productId).toString();
                },
                backgroundColor: Colors.brown,
                foregroundColor: Colors.white,
                child: const Icon(
                  Iconsax.edit,
                  color: CColors.white,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
