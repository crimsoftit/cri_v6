import 'package:cri_v6/common/widgets/shimmers/vert_items_shimmer.dart';
import 'package:cri_v6/features/personalization/controllers/contacts_controller.dart';
import 'package:cri_v6/features/personalization/models/contacts_model.dart';
import 'package:cri_v6/features/personalization/screens/no_data/no_data_screen.dart';
import 'package:cri_v6/utils/constants/colors.dart';
import 'package:cri_v6/utils/constants/img_strings.dart';
import 'package:cri_v6/utils/constants/sizes.dart';
import 'package:cri_v6/utils/helpers/helper_functions.dart';
import 'package:cri_v6/utils/popups/snackbars.dart';
import 'package:cri_v6/utils/validators/validation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CContactsListview extends StatefulWidget {
  const CContactsListview({
    super.key,
    required this.space,
  });
  final String space;

  @override
  State<CContactsListview> createState() => _CContactsListviewState();
}

class _CContactsListviewState extends State<CContactsListview> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final contactsController = Get.put(CContactsController());
    final isDarkTheme = CHelperFunctions.isDarkMode(context);
    var demContacts = <CContactsModel>[];

    return Obx(
      () {
        demContacts.clear;
        switch (widget.space) {
          case 'all':
            demContacts.clear;
            if (contactsController.showContactsSearchField.value &&
                contactsController.contactsSearchFieldController.text.trim() !=
                    '') {
              demContacts.assignAll(
                contactsController.allContactMatches.where(
                  (contact) => contact.isTrashed == 0,
                ),
              );
            } else {
              demContacts.assignAll(
                contactsController.myContacts.where(
                  (contact) => contact.isTrashed == 0,
                ),
              );
            }

            break;
          case 'customers':
            demContacts.clear;
            if (contactsController.showContactsSearchField.value &&
                contactsController.contactsSearchFieldController.text.trim() !=
                    '') {
              demContacts.assignAll(
                contactsController.allContactMatches.where(
                  (match) =>
                      match.contactCategory.toLowerCase().contains(
                        'customer'.toLowerCase(),
                      ) &&
                      match.isTrashed == 0,
                ),
              );
            } else {
              demContacts.assignAll(
                contactsController.myContacts.where(
                  (contact) =>
                      contact.contactCategory.toLowerCase().contains(
                        'customer'.toLowerCase(),
                      ) &&
                      contact.isTrashed == 0,
                ),
              );
            }

            break;
          case 'friends':
            demContacts.clear;
            if (contactsController.showContactsSearchField.value &&
                contactsController.contactsSearchFieldController.text.trim() !=
                    '') {
              demContacts.assignAll(
                contactsController.allContactMatches.where(
                  (contact) =>
                      contact.contactCategory.toLowerCase().contains(
                        'friend'.toLowerCase(),
                      ) &&
                      contact.isTrashed == 0,
                ),
              );
            } else {
              demContacts.assignAll(
                contactsController.myContacts.where(
                  (contact) =>
                      contact.contactCategory.toLowerCase().contains(
                        'friend'.toLowerCase(),
                      ) &&
                      contact.isTrashed == 0,
                ),
              );
            }

            break;
          case 'suppliers':
            demContacts.clear();
            if (contactsController.showContactsSearchField.value &&
                contactsController.contactsSearchFieldController.text.trim() !=
                    '') {
              demContacts.assignAll(
                contactsController.allContactMatches.where(
                  (contact) =>
                      contact.contactCategory.toLowerCase().contains(
                        'supplier'.toLowerCase(),
                      ) &&
                      contact.isTrashed == 0,
                ),
              );
            } else {
              demContacts.assignAll(
                contactsController.myContacts.where(
                  (contact) =>
                      contact.contactCategory.toLowerCase().contains(
                        'supplier'.toLowerCase(),
                      ) &&
                      contact.isTrashed == 0,
                ),
              );
            }

            break;
          case 'trashed':
            demContacts.clear();
            if (contactsController.showContactsSearchField.value &&
                contactsController.contactsSearchFieldController.text.trim() !=
                    '') {
              demContacts.assignAll(
                contactsController.allContactMatches.where(
                  (contact) => contact.isTrashed == 1,
                ),
              );
            } else {
              demContacts.assignAll(
                contactsController.myContacts.where(
                  (contact) => contact.isTrashed == 1,
                ),
              );
            }

            break;
          default:
            demContacts.clear();

            if (kDebugMode) {
              CPopupSnackBar.errorSnackBar(
                message: 'no contacts for this tab space!',
                title: 'invalid tab space',
              );
            }
        }

        // if (contactsController.isImportingContacts.value ||
        //     (demContacts.isNotEmpty &&
        //         (contactsController.isLoading.value ||
        //             contactsController.processingContactsSync.value))) {
        //   return const CVerticalProductShimmer(itemCount: 6,);
        // }
        if (contactsController.isImportingContacts.value ||
            contactsController.isLoading.value ||
            contactsController.processingContactsSync.value) {
          return const CVerticalProductShimmer(
            itemCount: 6,
          );
        }

        if (demContacts.isEmpty &&
            !contactsController.isLoading.value &&
            !contactsController.processingContactsSync.value) {
          return Center(
            child: NoDataScreen(
              lottieImage: CImages.pencilAnimation,
              txt: widget.space == 'all'
                  ? 'All your contacts appear here...'
                  : widget.space == 'trashed'
                  ? 'Your trashed contacts appear here...'
                  : 'Your ${widget.space}\' contacts appear here...',
            ),
          );
        }

        /// -- grouping logic --

        Map<String, List<CContactsModel>> groupedContacts = {};
        demContacts.sort(
          (a, b) {
            return a.contactName.compareTo(b.contactName);
          },
        );

        for (var contact in demContacts) {
          String initial = contact.contactName[0].toUpperCase();
          if (!groupedContacts.containsKey(initial)) {
            groupedContacts[initial] = [];
          }

          groupedContacts[initial]!.add(contact);
        }

        // SuspensionUtil.sortListBySuspensionTag(demContacts);
        // SuspensionUtil.setShowSuspensionStatus(demContacts);

        return ListView.builder(
          itemCount: groupedContacts.keys.length,
          itemBuilder: (context, groupIndex) {
            String letter = groupedContacts.keys.elementAt(groupIndex);
            List<CContactsModel> contacts = groupedContacts[letter]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Section Header (e.g., "A")
                Padding(
                  padding: const EdgeInsets.only(
                    right: 15.0,
                    top: 7.0,
                  ),
                  child: Text(
                    letter,
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                // Inner ListView for contacts in this group
                Card(
                  color: isDarkTheme
                      ? CColors.rBrown.withValues(
                          alpha: 0.3,
                        )
                      : CColors.lightGrey,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      CSizes.borderRadiusLg,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true, // Prevents overflow
                      physics:
                          NeverScrollableScrollPhysics(), // Disables inner scrolling
                      itemCount: contacts.length,
                      itemBuilder: (context, itemIndex) {
                        return InkWell(
                          onTap: () {
                            setState(
                              () {
                                _isExpanded = !_isExpanded;
                              },
                            );
                          },
                          child: ListTile(
                            contentPadding: EdgeInsets.fromLTRB(
                              5.0,
                              2.0,
                              1.0,
                              2.0,
                            ),
                            horizontalTitleGap: 0.1,
                            leading: null,
                            subtitle: Column(),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      CHelperFunctions.randomAestheticColor(),
                                  radius: 20.0,
                                  child:
                                      CValidator.isFirstCharacterALetter(
                                        contacts[itemIndex].contactName,
                                      )
                                      ? Text(
                                          contacts[itemIndex].contactName[0]
                                              .toUpperCase(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .apply(
                                                color: CColors.white,
                                              ),
                                        )
                                      : Icon(
                                          Iconsax.user,
                                          color:
                                              CHelperFunctions.randomAestheticColor(),
                                        ),
                                ),
                                const SizedBox(
                                  width: CSizes.spaceBtnItems,
                                ),
                                SelectableText(
                                  contacts[itemIndex].contactName,
                                  maxLines: 1,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .apply(
                                        fontSizeFactor: 1.1,
                                      ),
                                ),
                              ],
                            ),
                            titleAlignment: ListTileTitleAlignment.top,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        );

        // ListView.builder(
        //   itemCount: demContacts.length,
        //   itemBuilder: (context, index) {
        //     // Initialize selection state if not present
        //     if (!_selectedItems.containsKey(index)) {
        //       _selectedItems[index] = false;
        //     }
        //     return Column(
        //       children: [
        //         ListTile(
        //           title: Text(demContacts[index].contactName),
        //           subtitle: Text(demContacts[index].contactPhone),
        //         ),
        //         AnimatedCrossFade(
        //           firstChild: SizedBox.shrink(),
        //           secondChild: Text(
        //             demContacts[index].contactEmail,
        //           ),
        //           crossFadeState: _selectedItems[index]!
        //               ? CrossFadeState.showFirst
        //               : CrossFadeState.showSecond,
        //           duration: Duration(
        //             milliseconds: 300,
        //           ),
        //         ),
        //       ],
        //     );
        //   },
        // );
      },
    );
  }

  // Custom widget for each list item
  Widget getWeChatListItem(BuildContext context, CContactsModel contact) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ListTile(
        title: Text(contact.contactName),
        // You can access model.tagIndex if you need to display the header manually,
        // but AzListView handles sticky headers automatically.
      ),
    );
  }
}
