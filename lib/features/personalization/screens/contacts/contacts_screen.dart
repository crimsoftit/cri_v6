import 'package:cri_v6/common/widgets/appbar/app_bar.dart';
import 'package:cri_v6/common/widgets/appbar/tab_bar.dart';
import 'package:cri_v6/common/widgets/shimmers/shimmer_effects.dart';
import 'package:cri_v6/features/personalization/controllers/contacts_controller.dart';
import 'package:cri_v6/features/personalization/screens/contacts/widgets/animed_searchfield.dart';
import 'package:cri_v6/features/personalization/screens/contacts/widgets/contacts_listview.dart';
import 'package:cri_v6/utils/constants/colors.dart';
import 'package:cri_v6/utils/constants/sizes.dart';
import 'package:cri_v6/utils/helpers/helper_functions.dart';
import 'package:cri_v6/utils/helpers/network_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_floaty/flutter_floaty.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CContactsScreen extends StatelessWidget {
  const CContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final contactsController = Get.put(CContactsController());
    final isDarkTheme = CHelperFunctions.isDarkMode(context);

    return DefaultTabController(
      animationDuration: Duration(milliseconds: 300),
      length: 5,
      child: Container(
        color: isDarkTheme ? CColors.transparent : CColors.white,
        child: Obx(
          /// -- define boundaries for the floating action button --
          () {
            final fabBoundaries = Rect.fromLTRB(
              0.0,
              0.0,
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height * 0.9,
            );
            return Scaffold(
              /// -- app bar --
              appBar: CAppBar(
                horizontalPadding: 0,
                leadingWidget: contactsController.showContactsSearchField.value
                    ? null
                    : Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 5.0,
                            left: 10.0,
                          ),
                          child: Icon(
                            Iconsax.menu,
                            size: CSizes.iconMd,
                            color: CColors.rBrown,
                          ),
                        ),
                      ),
                showBackArrow: false,
                backIconColor: isDarkTheme ? CColors.white : CColors.rBrown,
                title: Obx(() {
                  return Center(
                    child: CAnimedSearchfield(
                      fieldExpanded:
                          contactsController.showContactsSearchField.value,
                      hintTxt: 'search contacts...',
                      onFieldSubmitted: (value) {
                        // contactsController.toggleSearchFieldDisplay();
                        contactsController.searchThroughContacts(value);
                      },

                      onIconTap: () {
                        contactsController.toggleSearchFieldDisplay();
                      },
                      onSearchValueChanged: (query) {
                        contactsController.searchThroughContacts(query);
                      },
                      searchFieldController:
                          contactsController.contactsSearchFieldController,
                    ),
                  );
                }),
                backIconAction: () {
                  // Navigator.pop(context, true);
                },
              ),
              backgroundColor: CColors.rBrown.withValues(
                alpha: 0.2,
              ),
              resizeToAvoidBottomInset: true,
              body: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      automaticallyImplyLeading: true,
                      backgroundColor: CColors.transparent,

                      expandedHeight: 50.0,
                      flexibleSpace: Padding(
                        padding: const EdgeInsets.only(
                          left: 10.0,
                          right: 10.0,
                        ),
                        child: Obx(() {
                          return ListView(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            children: [
                              // CStoreScreenHeader(
                              //   forStoreScreen: false,
                              //   title: 'Contacts',
                              // ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Contacts',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge!
                                        .apply(
                                          color:
                                              CNetworkManager
                                                  .instance
                                                  .hasConnection
                                                  .value
                                              ? CColors.rBrown
                                              : CColors.darkGrey,
                                          fontSizeFactor: 2.5,
                                          fontWeightDelta: -7,
                                        ),
                                  ),

                                  /// -- button to import contacts from device --
                                  Row(
                                    children: [
                                      /// -- button to synchronize local contacts with cloud --
                                      contactsController
                                              .processingContactsSync
                                              .value
                                          ? CShimmerEffect(
                                              width: 40.0,
                                              height: 40.0,
                                              radius: 40.0,
                                            )
                                          : IconButton(
                                              onPressed:
                                                  contactsController
                                                          .unsyncedContactAppends
                                                          .isEmpty &&
                                                      contactsController
                                                          .unsyncedContactUpdates
                                                          .isEmpty &&
                                                      contactsController
                                                          .cloudDelContacts
                                                          .isEmpty
                                                  ? null
                                                  : () async {
                                                      contactsController
                                                          .processContactsSync();
                                                    },
                                              icon: Icon(
                                                contactsController
                                                            .unsyncedContactAppends
                                                            .isEmpty &&
                                                        contactsController
                                                            .unsyncedContactUpdates
                                                            .isEmpty &&
                                                        contactsController
                                                            .cloudDelContacts
                                                            .isEmpty
                                                    ? Iconsax.cloud_add
                                                    : Iconsax.cloud_change,
                                                color:
                                                    CNetworkManager
                                                        .instance
                                                        .hasConnection
                                                        .value
                                                    ? CColors.rBrown
                                                    : CColors.darkGrey,
                                              ),
                                            ),

                                      /// -- button to take user to trashed contacts screen --
                                      IconButton(
                                        onPressed: () async {},
                                        icon: Icon(
                                          Iconsax.trash,
                                          color:
                                              CNetworkManager
                                                  .instance
                                                  .hasConnection
                                                  .value
                                              ? CColors.rBrown
                                              : CColors.darkGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                            ],
                          );
                        }),
                      ),
                      bottom: const CTabBar(
                        tabs: [
                          Tab(
                            child: Text(
                              'All',
                            ),
                          ),
                          Tab(
                            child: Text(
                              'Suppliers',
                            ),
                          ),
                          Tab(
                            child: Text(
                              'Customers',
                            ),
                          ),

                          Tab(
                            child: Text(
                              'Friends',
                            ),
                          ),

                          Tab(
                            child: Text(
                              'Device',
                            ),
                          ),
                        ],
                      ),
                      floating: false,
                      pinned: true,
                    ),
                  ];
                },
                body: const TabBarView(
                  physics: BouncingScrollPhysics(),
                  children: [
                    CContactsListview(
                      space: 'all',
                    ),
                    CContactsListview(
                      space: 'suppliers',
                    ),
                    CContactsListview(
                      space: 'customers',
                    ),
                    CContactsListview(
                      space: 'friends',
                    ),
                    CContactsListview(
                      space: 'device',
                    ),
                  ],
                ),
              ),
              floatingActionButton: Stack(
                children: [
                  FlutterFloaty(
                    backgroundColor:
                        CNetworkManager.instance.hasConnection.value
                        ? CColors.rBrown
                        : CColors.black,
                    borderRadius: 15.0,
                    builder: (context) {
                      return Column(
                        children: [
                          contactsController.isImportingContacts.value
                              ? CShimmerEffect(
                                  width: 40.0,
                                  height: 40.0,
                                  radius: 40.0,
                                )
                              : IconButton(
                                  onPressed: () async {
                                    await contactsController
                                        .importDeviceContacts();
                                  },
                                  icon: Icon(
                                    Iconsax.import,
                                    color: CColors.white,
                                  ),
                                ),
                          const SizedBox(
                            height: CSizes.spaceBtnItems,
                          ),
                          InkWell(
                            onTap: () async {
                              await contactsController.addContactActionModal(
                                context,
                              );
                            },
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      );
                    },
                    growingFactor: 1.1,
                    height: 100.0,
                    initialX: CHelperFunctions.screenWidth() * .80,
                    initialY: CHelperFunctions.screenHeight() * .71,
                    intrinsicBoundaries: fabBoundaries,
                    onDragBackgroundColor:
                        CNetworkManager.instance.hasConnection.value
                        ? CColors.rBrown.withValues(alpha: .4,)
                        : CColors.black.withValues(alpha: .4,),

                    // Circular shape
                    onTap: () {},
                    shape: BoxShape.rectangle,
                    width: 60,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
