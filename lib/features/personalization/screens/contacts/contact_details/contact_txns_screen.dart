import 'package:cri_v6/common/widgets/anime/animated_digit_widget.dart';
import 'package:cri_v6/common/widgets/appbar/tab_bar.dart';
import 'package:cri_v6/features/personalization/controllers/contacts_controller.dart';
import 'package:cri_v6/features/personalization/controllers/user_controller.dart';
import 'package:cri_v6/features/store/screens/store_items_tings/widgets/txn_items.dart';
import 'package:cri_v6/utils/constants/colors.dart';
import 'package:cri_v6/utils/constants/sizes.dart';
import 'package:cri_v6/utils/helpers/helper_functions.dart';
import 'package:cri_v6/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CContactTxnsScreen extends StatelessWidget {
  const CContactTxnsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final contactsController = Get.put(CContactsController());
    final isDarkTheme = CHelperFunctions.isDarkMode(context);

    final userController = Get.put(CUserController());
    final userCurrency = CHelperFunctions.formatCurrency(
      userController.user.value.currencyCode,
    );

    final thisContact = contactsController.myContacts.firstWhere(
      (contact) => contact.contactId == Get.arguments,
    );
    return DefaultTabController(
      animationDuration: Duration(milliseconds: 300),
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          elevation: 1.0,
          shadowColor: CColors.rBrown.withValues(
            alpha: 0.1,
          ),
          iconTheme: IconThemeData(
            color: isDarkTheme ? CColors.white : CColors.rBrown,
          ),
          title: Text(
            '',
            style: Theme.of(context).textTheme.labelMedium!.apply(
              color: isDarkTheme ? CColors.grey : CColors.rBrown,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                Iconsax.star,
                color: isDarkTheme ? CColors.white : CColors.rBrown,
                size: CSizes.iconMd,
              ),
            ),
            IconButton(
              onPressed: () async {
                await contactsController.updateContactActionModal(
                  context,
                  thisContact,
                  'edit',
                );
                await contactsController.fetchMyContacts();
              },
              icon: Icon(
                Iconsax.edit,
                color: isDarkTheme ? CColors.white : CColors.rBrown,
                size: CSizes.iconMd,
              ),
            ),

            // IconButton(
            //   onPressed: () {

            //   },
            //   icon: Icon(
            //     Iconsax.notification,
            //     color: isDarkTheme ? CColors.white : CColors.rBrown,
            //   ),
            // ),
          ],
        ),
        backgroundColor: CColors.rBrown.withValues(
          alpha: 0.2,
        ),
        body: Obx(
          () {
            /// -- summarize contact txns --
            contactsController.summarizeContactTxns(
              thisContact.contactName,
              thisContact.contactPhone,
              thisContact.contactEmail,
            );
            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrollable) {
                return [
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    expandedHeight: 250.0,
                    pinned: true,
                    floating: true,
                    snap: true,
                    backgroundColor: CColors.transparent,
                    elevation: 0.0,
                    flexibleSpace: Padding(
                      padding: const EdgeInsets.only(
                        left: 30.0,
                        right: 30.0,
                      ),
                      child: ListView(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        children: [
                          Column(
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 10.0,
                                    top: 20.0,
                                  ),
                                  child: CircleAvatar(
                                    backgroundColor:
                                        CHelperFunctions.randomAestheticColor(),
                                    radius: 40.0,
                                    child:
                                        CValidator.isFirstCharacterALetter(
                                          thisContact.contactName,
                                        )
                                        ? Text(
                                            thisContact.contactName[0]
                                                .toUpperCase(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .apply(
                                                  color: CColors.white,
                                                  fontSizeFactor: 2.0,
                                                ),
                                          )
                                        : Icon(
                                            Iconsax.user,
                                            color:
                                                CHelperFunctions.randomAestheticColor(),
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: CSizes.spaceBtnItems / 2.0,
                              ),
                              Text(
                                thisContact.contactName,
                                style: Theme.of(context).textTheme.labelLarge!
                                    .apply(
                                      color: isDarkTheme
                                          ? CColors.white
                                          : CColors.rBrown,
                                      fontSizeFactor: 2.0,
                                      fontWeightDelta: -7,
                                    ),
                              ),
                              const SizedBox(
                                height: CSizes.spaceBtnItems / 2.0,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Txns',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge!
                                        .apply(
                                          color: isDarkTheme
                                              ? CColors.white
                                              : CColors.rBrown,
                                          fontSizeFactor: 1.5,
                                          fontWeightDelta: -7,
                                        ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        userCurrency,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall!
                                            .apply(
                                              fontFeatures: [
                                                FontFeature.superscripts(),
                                              ],
                                            ),
                                      ),
                                      CAnimatedDigitWidget(
                                        fractionDigits: 1,
                                        prefix: '',
                                        txtStyle: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .apply(
                                              color: CColors.rOrange,
                                              fontSizeFactor: 1.5,
                                              fontWeightDelta: 2,
                                            ),
                                        value: contactsController
                                            .contactTotalTxnsValue
                                            .value,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 1.0,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    shadowColor: CColors.rBrown.withValues(
                      alpha: 0.1,
                    ),

                    /// -- tabs --
                    bottom: CTabBar(
                      tabs: [
                        Tab(
                          text:
                              'Credit - $userCurrency.${contactsController.contactInvoicedTxnsValue.value}',
                        ),

                        Tab(
                          text: 'Receipts',
                        ),
                        Tab(
                          child: Text(
                            'Refunds',
                          ),
                        ),
                        Tab(
                          child: Text(
                            'Supplies',
                          ),
                        ),
                      ],
                    ),
                  ),
                ];
              },
              body: TabBarView(
                children: [
                  /// -- transactions list view --
                  CTxnItemsListView(
                    forContactScreen: true,
                    space: 'contact invoices',
                  ),
                  CTxnItemsListView(
                    forContactScreen: true,
                    space: 'contact receipts',
                  ),

                  CTxnItemsListView(
                    forContactScreen: true,
                    space: 'contact refunds',
                  ),
                  Center(child: Text('Supplies')),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
