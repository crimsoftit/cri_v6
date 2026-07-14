import 'package:cri_v6/common/widgets/shimmers/vert_items_shimmer.dart';
import 'package:cri_v6/features/personalization/controllers/contacts_controller.dart';
import 'package:cri_v6/features/personalization/models/contacts_model.dart';
import 'package:cri_v6/features/personalization/screens/no_data/no_data_screen.dart';
import 'package:cri_v6/features/store/screens/search/widgets/no_results_screen.dart';
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

class CContactsListview extends StatelessWidget {
  const CContactsListview({
    super.key,
    required this.space,
  });
  final String space;

  @override
  Widget build(BuildContext context) {
    final contactsController = Get.put(CContactsController());
    final isDarkTheme = CHelperFunctions.isDarkMode(context);
    var demContacts = <CContactsModel>[];

    return Obx(
      () {
        demContacts.clear;
        switch (space) {
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
          case 'device':
            demContacts.clear();
            if (contactsController.showContactsSearchField.value &&
                contactsController.contactsSearchFieldController.text.trim() !=
                    '') {
              demContacts.assignAll(
                contactsController.allContactMatches.where(
                  (contact) {
                    return contact.contactCategory.toLowerCase().contains(
                          'device'.toLowerCase(),
                        ) &&
                        contact.isTrashed == 0;
                  },
                ),
              );
            } else {
              demContacts.assignAll(
                contactsController.myContacts.where(
                  (contact) {
                    return contact.contactCategory.toLowerCase().contains(
                          'device'.toLowerCase(),
                        ) &&
                        contact.isTrashed == 0;
                  },
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

        /// -- no data screen logic --
        if (demContacts.isEmpty &&
            !contactsController.isLoading.value &&
            !contactsController.processingContactsSync.value &&
            !contactsController.showContactsSearchField.value) {
          return Center(
            child: NoDataScreen(
              lottieImage: CImages.pencilAnimation,
              txt: space == 'all'
                  ? 'All your contacts appear here...'
                  : space == 'trashed'
                  ? 'Your trashed contacts appear here...'
                  : 'Your $space\' contacts appear here...',
            ),
          );
        }

        /// -- no search results logic --
        if (demContacts.isEmpty &&
            contactsController.showContactsSearchField.value) {
          return const NoSearchResultsScreen();
        }

        /// -- grouping logic --

        Map<String, List<CContactsModel>> groupedContacts = {};
        demContacts.sort(
          (a, b) {
            return a.contactName.trim().toLowerCase().compareTo(
              b.contactName.trim().toLowerCase(),
            );
          },
        );

        for (var contact in demContacts) {
          String initial =
              CValidator.isFirstCharacterALetter(contact.contactName.trim())
              ? contact.contactName[0].toUpperCase()
              : '...';
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
                    style: Theme.of(context).textTheme.labelSmall,
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
                    child: ListView.separated(
                      shrinkWrap: true, // Prevents overflow
                      physics:
                          NeverScrollableScrollPhysics(), // Disables inner scrolling
                      itemCount: contacts.length,
                      itemBuilder: (context, itemIndex) {
                        return InkWell(
                          onTap: () {
                            Get.toNamed(
                              '/my_contacts/contact_details',
                              arguments: contacts[itemIndex].contactId,
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
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
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
                                          color: CColors.white,
                                          size: CSizes.iconSm,
                                        ),
                                ),
                                const SizedBox(
                                  width: CSizes.spaceBtnItems,
                                ),
                                Text(
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
                      separatorBuilder: (context, index) {
                        return Divider(
                          color: CColors.rBrown,
                          endIndent: 20.0,
                          indent: 60.0,
                          thickness: .3,
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
