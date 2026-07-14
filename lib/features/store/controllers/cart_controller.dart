import 'package:cri_v6/common/widgets/anime/animated_digit_widget.dart';
import 'package:cri_v6/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:cri_v6/features/personalization/controllers/user_controller.dart';
import 'package:cri_v6/features/store/controllers/checkout_controller.dart';
import 'package:cri_v6/features/store/controllers/inv_controller.dart';
import 'package:cri_v6/features/store/models/cart_item_model.dart';
import 'package:cri_v6/features/store/models/inv_model.dart';
import 'package:cri_v6/features/store/screens/store_items_tings/checkout/checkout_screen.dart';
import 'package:cri_v6/features/store/screens/store_items_tings/checkout/widgets/amt_issued_field.dart';
import 'package:cri_v6/utils/computations/date_time_computations.dart';
import 'package:cri_v6/utils/constants/colors.dart';
import 'package:cri_v6/utils/constants/sizes.dart';
import 'package:cri_v6/utils/helpers/formatter.dart';
import 'package:cri_v6/utils/helpers/helper_functions.dart';
import 'package:cri_v6/utils/local_storage/storage_utility.dart';
import 'package:cri_v6/utils/popups/snackbars.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CCartController extends GetxController {
  static CCartController get instance => Get.find();

  /// -- variables --
  RxDouble taxFee = 0.0.obs;
  RxDouble totalCartPrice = 0.0.obs;
  final RxDouble totalDiscount = 0.0.obs;

  final RxBool cartItemsLoading = false.obs;
  final RxBool displaySaveBtnOnCheckOutItems = false.obs;
  final userController = Get.put(CUserController());

  final RxDouble countOfCartItems = 0.0.obs;
  RxDouble itemQtyInCart = 0.0.obs;

  RxList<CCartItemModel> cartItems = <CCartItemModel>[].obs;

  RxList<TextEditingController> qtyFieldControllers =
      <TextEditingController>[].obs;

  final discountFieldController = TextEditingController();

  // CCartController() {
  //   fetchCartItems();
  // }

  @override
  void onInit() async {
    cartItemsLoading.value = false;
    displaySaveBtnOnCheckOutItems.value = false;
    qtyFieldControllers.clear();

    cartItems.clear();

    await fetchCartItems();

    super.onInit();
  }

  /// -- fetch cart items from device storage --
  Future<bool> fetchCartItems() async {
    try {
      cartItemsLoading.value = true;

      final cartItemsStrings = CLocalStorage.instance().readData<List<dynamic>>(
        'cartItems',
      );

      if (cartItemsStrings != null) {
        cartItems.assignAll(
          cartItemsStrings.map(
            (item) => CCartItemModel.fromJson(item as Map<String, dynamic>),
          ),
        );

        updateCartTotals();
      }
      cartItemsLoading.value = false;
      return true;
    } catch (e) {
      if (kDebugMode) {
        CPopupSnackBar.errorSnackBar(
          message: 'Error fetching cart items: $e',
          title: 'Error fetching cart items!',
        );
      } else {
        CPopupSnackBar.errorSnackBar(
          message:
              'an unknown error occurred while fetching cart items!  Please try again later...',
          title: 'Error fetching cart items!',
        );
      }
      rethrow;
    } finally {
      cartItemsLoading.value = false;
    }
  }

  /// -- add items to cart --
  void addToCart(CInventoryModel item) {
    // qty check
    if (itemQtyInCart.value < 0.1) {
      CPopupSnackBar.customToast(
        message: 'select quantity',
        forInternetConnectivityStatus: false,
      );
      return;
    }
    if (item.expiryDate != '') {
      var itemExpiry = CDateTimeComputations.timeRangeFromNow(
        item.expiryDate.replaceAll('@ ', ''),
      );
      if (itemExpiry <= 0) {
        CPopupSnackBar.warningSnackBar(
          title: 'item is stale/expired',
          message: '${item.name} is stale/expired!',
        );
        return;
      }
    }
    if (item.quantity < 0.01) {
      CPopupSnackBar.warningSnackBar(
        title: 'oh snap!',
        message: '${item.name} is out of stock!!',
      );
      return;
    }
    if (itemQtyInCart > item.quantity) {
      CPopupSnackBar.warningSnackBar(
        title: 'oh snap!',
        message: item.quantity == 0
            ? 'Oh no! \n${item.name.toUpperCase()} is out of stock!'
            : item.quantity == 1
            ? 'only 1 ${CFormatter.formatItemMetrics(item.calibration, item.quantity)} of ${item.name.toUpperCase()} is stocked!'
            : 'only ${CFormatter.formatItemQtyDisplays(item.quantity, item.calibration)} ${CFormatter.formatItemMetrics(item.calibration, item.quantity)} of ${item.name.toUpperCase()} are stocked!',
      );
      return;
    }

    // convert the CInventoryModel to a CCartItemModel
    final selectedCartItem = convertInvToCartItem(item, itemQtyInCart.value);

    // check if selected cart item already exists in the cart

    int userCartItemIndex = cartItems.indexWhere(
      (uCartItem) => uCartItem.productId == selectedCartItem.productId,
    );

    if (userCartItemIndex >= 0) {
      // item already added to cart
      cartItems[userCartItemIndex].quantity = selectedCartItem.quantity;
      qtyFieldControllers[userCartItemIndex].text =
          cartItems[userCartItemIndex].itemMetrics == 'units'
          ? cartItems[userCartItemIndex].quantity.toStringAsFixed(0)
          : cartItems[userCartItemIndex].quantity.toStringAsFixed(2);
    } else {
      cartItems.add(selectedCartItem);
      qtyFieldControllers.add(
        TextEditingController(
          text: CFormatter.formatItemQtyDisplays(
            selectedCartItem.availableStockQty,
            selectedCartItem.itemMetrics,
          ),
        ),
      );
      updateCart();
    }

    // update cart for specific user
    updateCart();
    CPopupSnackBar.customToast(
      message: 'item successfully added to cart',
      forInternetConnectivityStatus: false,
    );
  }

  /// -- add a single item to cart --
  Future<void> addSingleItemToCart(
    CCartItemModel item,
    bool fromQtyTxtField,
    String? qtyValue,
  ) async {
    fetchCartItems();
    int itemIndex = cartItems.indexWhere(
      (cartItem) => cartItem.productId == item.productId,
    );

    // switch (itemIndex) {
    //   case < 0:
    //     break;
    //   default:
    // }

    // -- check stock qty --
    final invController = Get.put(CInventoryController());
    final inventoryItem = invController.inventoryItems.firstWhere(
      (invItem) => invItem.productId == item.productId,
    );

    if (inventoryItem.expiryDate != '' &&
        CDateTimeComputations.timeRangeFromNow(
              inventoryItem.expiryDate.replaceAll('@ ', ''),
            ) <=
            0) {
      CPopupSnackBar.warningSnackBar(
        title: 'item is stale/expired',
        message: '${inventoryItem.name} has expired!',
      );
      return;
    } else {
      if (inventoryItem.quantity > 0) {
        if (itemIndex >= 0) {
          if (fromQtyTxtField && qtyValue != '') {
            if (double.parse(qtyValue!) > inventoryItem.quantity) {
              CPopupSnackBar.warningSnackBar(
                title: 'Oh snap!',
                message: inventoryItem.quantity == 0
                    ? 'Oh no! \n${inventoryItem.name.toUpperCase()} is out of stock!'
                    : item.quantity == 1
                    ? 'only 1 ${CFormatter.formatItemMetrics(inventoryItem.calibration, inventoryItem.quantity)} of ${inventoryItem.name.toUpperCase()} is stocked!'
                    : 'only ${CFormatter.formatItemQtyDisplays(inventoryItem.quantity, inventoryItem.calibration)} ${CFormatter.formatItemMetrics(inventoryItem.calibration, inventoryItem.quantity)} of ${inventoryItem.name.toUpperCase()} are stocked!',
              );
              qtyFieldControllers[itemIndex].text =
                  inventoryItem.calibration == 'units'
                  ? inventoryItem.quantity.toInt().toString()
                  : inventoryItem.quantity.toStringAsFixed(2);
              qtyValue = qtyFieldControllers[itemIndex].text;
              return;
            }
            cartItems[itemIndex].quantity = double.parse(qtyValue);
            updateCart().then((_) {
              qtyFieldControllers[itemIndex].text =
                  cartItems[itemIndex].itemMetrics == 'units'
                  ? cartItems[itemIndex].quantity.toInt().toString()
                  : cartItems[itemIndex].quantity.toStringAsFixed(2);
            });
          } else {
            if (cartItems[itemIndex].quantity >= inventoryItem.quantity) {
              CPopupSnackBar.warningSnackBar(
                title: 'oh snap!',
                message: inventoryItem.quantity == 1
                    ? 'Only ${CFormatter.formatItemQtyDisplays(inventoryItem.quantity, inventoryItem.calibration)} ${CFormatter.formatItemMetrics(inventoryItem.calibration, inventoryItem.quantity)} of ${inventoryItem.name.toUpperCase()} is stocked!'
                    : 'Only ${CFormatter.formatItemQtyDisplays(inventoryItem.quantity, inventoryItem.calibration)} ${CFormatter.formatItemMetrics(inventoryItem.calibration, inventoryItem.quantity)} of ${inventoryItem.name.toUpperCase()} are stocked!',
              );
              qtyFieldControllers[itemIndex].text =
                  inventoryItem.calibration == 'units'
                  ? inventoryItem.quantity.toInt().toString()
                  : inventoryItem.quantity.toString();
              return;
            } else {
              cartItems[itemIndex].quantity +=
                  cartItems[itemIndex].itemMetrics == 'units' ? 1 : .1;
              updateCart().then((_) {
                qtyFieldControllers[itemIndex].text =
                    cartItems[itemIndex].itemMetrics == 'units'
                    ? cartItems[itemIndex].quantity.toInt().toString()
                    : cartItems[itemIndex].quantity.toStringAsFixed(2);
              });
            }
          }
        } else {
          cartItems.add(item);
          updateCart();
          qtyFieldControllers.add(
            TextEditingController(
              text: item.itemMetrics == 'units'
                  ? item.quantity.toInt().toString()
                  : item.quantity.toStringAsFixed(2),
            ),
          );
        }
      } else {
        CPopupSnackBar.warningSnackBar(
          title: 'Oh snap!',
          message: '${inventoryItem.name.toUpperCase()} is out of stock!',
        );
      }
      updateCart();
    }
  }

  /// -- decrement cart item qty/remove a single item from the cart --
  void removeSingleItemFromCart(CCartItemModel item, bool showConfirmDialog) {
    int removeItemIndex = cartItems.indexWhere((itemToRemove) {
      return itemToRemove.productId == item.productId;
    });

    if (removeItemIndex >= 0) {
      if ((cartItems[removeItemIndex].quantity > 0.1 &&
              cartItems[removeItemIndex].itemMetrics != 'units') ||
          (cartItems[removeItemIndex].quantity > 1 &&
              cartItems[removeItemIndex].itemMetrics == 'units')) {
        cartItems[removeItemIndex].quantity -=
            cartItems[removeItemIndex].itemMetrics == 'units' ? 1 : .1;
      } else {
        if (showConfirmDialog) {
          // show confirm dialog before entirely removing
          (cartItems[removeItemIndex].quantity == 1 &&
                      cartItems[removeItemIndex].itemMetrics == 'units') ||
                  (cartItems[removeItemIndex].quantity == .1 &&
                      cartItems[removeItemIndex].itemMetrics != 'units')
              ? removeItemFromCartDialog(removeItemIndex, item.pName)
              : cartItems.removeAt(removeItemIndex);
          //updateCart();
        } else {
          // perform action to entirely remove this item from the cart
          cartItems.removeAt(removeItemIndex);
        }
      }
      updateCart();
      qtyFieldControllers[removeItemIndex].text =
          cartItems[removeItemIndex].itemMetrics == 'units'
          ? cartItems[removeItemIndex].quantity.toStringAsFixed(0)
          : cartItems[removeItemIndex].quantity.toStringAsFixed(2);
    }
  }

  /// -- confirm dialog before entirely removing item from cart --
  void removeItemFromCartDialog(int itemIndex, String itemToRemove) {
    Get.defaultDialog(
      barrierDismissible: false,
      middleText: 'Are you certain you wish to remove this item from the cart?',
      onCancel: () {
        //checkoutController.handleNavToCheckout();
        //Get.back();
        Get.to(() => const CCheckoutScreen());
      },
      onConfirm: () {
        // perform action to entirely remove this item from the cart
        cartItems.removeAt(itemIndex);
        qtyFieldControllers.removeAt(itemIndex);
        updateCart();

        CPopupSnackBar.customToast(
          message: '$itemToRemove removed from the cart...',
          forInternetConnectivityStatus: false,
        );
        Get.back();
        Get.to(() => const CCheckoutScreen());
        //
        //checkoutController.handleNavToCheckout();
      },
      title: 'Remove item?',
    );
  }

  /// -- convert a CInventoryModel to a CCartItemModel --
  CCartItemModel convertInvToCartItem(CInventoryModel item, double quantity) {
    return CCartItemModel(
      email: item.userEmail,
      productId: item.productId!,
      pCode: item.pCode,
      pName: item.name,
      itemMetrics: item.calibration,
      quantity: quantity,
      availableStockQty: item.quantity,
      price: item.unitSellingPrice,
    );
  }

  /// -- update cart content --
  Future updateCart() async {
    updateCartTotals();
    saveCartItems();
    cartItems.refresh();
    fetchCartItems();
  }

  /// -- update cart totals --
  void updateCartTotals() {
    double computedTotalCartPrice = 0.0;
    double computedCartItemsCount = 0;

    if (cartItems.isNotEmpty) {
      for (var item in cartItems) {
        computedTotalCartPrice += (item.price * item.quantity.toDouble());
        computedCartItemsCount += item.quantity;
      }

      countOfCartItems.value = computedCartItemsCount;
      totalCartPrice.value = computedTotalCartPrice;
      //txnTotals.value = totalCartPrice.value;
    } else {
      countOfCartItems.value = 0.0;
      totalCartPrice.value = 0.0;
      //txnTotals.value = 0.0;
    }
  }

  /// -- save cart items to device storage --
  void saveCartItems() async {
    final cartItemsStrings = cartItems.map((item) => item.toJson()).toList();
    //await CLocalStorage.instance().writeData('cartItems', cartItemsStrings);
    CLocalStorage.instance().writeData('cartItems', cartItemsStrings);
    //await localStorage.write('cartItems', cartItemsStrings);
  }

  /// -- get a specific item's quantity in the cart --
  double getItemQtyInCart(int pId) {
    //fetchCartItems(); <-- AVOID THIS KABSA... NOMA SANA -->
    final foundCartItemQty = cartItems
        .where((item) => item.productId == pId)
        .fold(
          0.0,
          (previousValue, element) => previousValue + element.quantity,
        );

    return foundCartItemQty;
  }

  /// -- set discount modal --
  void setDiscountDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // allow resizing
      useRootNavigator: true,
      useSafeArea: true,
      builder: (context) {
        final checkoutController = Get.put(CCheckoutController());
        final isDarkTheme = CHelperFunctions.isDarkMode(context);
        final userCurrency = CHelperFunctions.formatCurrency(
          userController.user.value.currencyCode,
        );

        discountFieldController.text = totalDiscount.value == 0 ? '' : totalDiscount.value.toString();
        return SingleChildScrollView(
          child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: CRoundedContainer(
              bgColor: CColors.transparent,
              // padding: MediaQuery.of(
              //   context,
              // ).padding,
              padding: EdgeInsets.only(
                bottom: 10.0, // dynamic padding for keyboard
                left: CSizes.lg,
                right: CSizes.lg,
                top: 10,
              ),
              height: CHelperFunctions.screenHeight() * .33,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min, // Important for proper resizing
                children: [
                  Text(
                    'Set discount...',
                    style: Theme.of(context).textTheme.titleMedium!.apply(),
                  ),
                  const SizedBox(
                    height: CSizes.spaceBtnSections,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Txn Amount:',
                        style: Theme.of(context).textTheme.titleMedium!.apply(
                          color: isDarkTheme ? CColors.white : CColors.rBrown,
                          fontSizeFactor: 1.2,
                          fontWeightDelta: 1,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            userCurrency,
                            style: Theme.of(context).textTheme.labelSmall!
                                .apply(
                                  fontFeatures: [
                                    FontFeature.superscripts(),
                                  ],
                                ),
                          ),
                          CAnimatedDigitWidget(
                            fractionDigits: 2,
                            prefix: '',
                            txtStyle: Theme.of(context).textTheme.titleMedium!
                                .apply(
                                  color: CColors.rOrange,
                                  fontSizeFactor: 1.5,
                                  fontWeightDelta: 1,
                                ),
                            value: totalCartPrice.value,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: CSizes.spaceBtnSections,
                  ),
                  CAmountTxtField(
                    fieldController: discountFieldController,
                    focusedBorderColor: isDarkTheme
                        ? CColors.white
                        : CColors.rBrown,
                    labelTxt: 'Enter discount amount',
                    onValueChanged: (discountAmt) {
                      if (discountAmt != '') {
                        totalDiscount.value = double.parse(
                          discountAmt!,
                        );
                      }
                    },
                    txtFieldWidth: CHelperFunctions.screenWidth() * .9,
                  ),
                  const SizedBox(
                    height: CSizes.spaceBtnItems,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CRoundedContainer(
                        bgColor: CColors.transparent,
                        width: CHelperFunctions.screenWidth() * .4,
                        child: TextButton.icon(
                          icon: Icon(
                            Iconsax.tick_square,
                            size: CSizes.iconSm,
                          ),
                          label: Text(
                            'Apply discount',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          onPressed: () async {
                            totalDiscount.value = double.parse(
                              discountFieldController.text.trim(),
                            );
                            checkoutController
                                .updateCustomerBalAfterDiscount(
                                  totalDiscount.value,
                                )
                                .then(
                                  (_) {
                                    discountFieldController.clear();
                                    Get.back();
                                  },
                                );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor:
                                CColors.white, // foreground (text) color
                            backgroundColor:
                                Colors.redAccent, // background color
                          ),
                        ),
                      ),

                      CRoundedContainer(
                        bgColor: CColors.transparent,
                        width: CHelperFunctions.screenWidth() * .4,
                        child: TextButton.icon(
                          icon: Icon(
                            Iconsax.undo,
                            size: CSizes.iconSm,
                          ),
                          label: Text(
                            'Cancel',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          onPressed: () {
                            totalDiscount.value = 0.0;
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor:
                                CColors.white, // foreground (text) color
                            backgroundColor: CColors.black.withValues(
                              alpha: .3,
                            ), // background color
                          ),
                        ),
                      ),
                    ],
                  ),
                  // CModalActionBtn(
                  //   btnTitle: 'apply discount',
                  //   onPressed: () {
                  //     if (discountFieldController.text.isNotEmpty) {
                  //       itemDiscount.value =
                  //           double.parse(discountFieldController.text.trim());
                  //       Get.back();
                  //     } else {
                  //       CPopupSnackBar.warningSnackBar(
                  //         title: 'discount field is empty!',
                  //         message:
                  //             'please enter a valid discount value to apply',
                  //       );
                  //     }
                  //   },
                  // ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// -- clear cart content --
  void clearCart() {
    itemQtyInCart.value = 0;
    countOfCartItems.value = 0;
    discountFieldController.clear();
    totalCartPrice.value = 0.0;
    totalDiscount.value = 0.0;
    cartItems.clear();
    updateCart();
  }

  /// -- initialize quantity of inventory item in the cart --
  void initializeItemCountInCart(CInventoryModel invItem) async {
    await Future.delayed(Duration.zero);
    itemQtyInCart.value = getItemQtyInCart(invItem.productId!);
  }

  @override
  void dispose() {
    qtyFieldControllers.clear();
    for (var controller in qtyFieldControllers) {
      controller.dispose();
    }
    discountFieldController.dispose();
    super.dispose();
  }
}
