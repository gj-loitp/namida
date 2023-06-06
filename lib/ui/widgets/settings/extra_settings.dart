import 'dart:async';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:namida/controller/current_color.dart';
import 'package:namida/controller/folders_controller.dart';
import 'package:namida/controller/indexer_controller.dart';
import 'package:namida/controller/settings_controller.dart';
import 'package:namida/controller/waveform_controller.dart';
import 'package:namida/core/constants.dart';
import 'package:namida/core/enums.dart';
import 'package:namida/core/extensions.dart';
import 'package:namida/core/icon_fonts/broken_icons.dart';
import 'package:namida/core/translations/strings.dart';
import 'package:namida/ui/widgets/custom_widgets.dart';
import 'package:namida/ui/widgets/settings_card.dart';

class ExtrasSettings extends StatelessWidget {
  const ExtrasSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      title: Language.inst.EXTRAS,
      subtitle: Language.inst.EXTRAS_SUBTITLE,
      icon: Broken.command_square,
      child: Column(
        children: [
          const CollapsedSettingTileWidget(),
          Obx(
            () => CustomSwitchListTile(
              icon: Broken.direct,
              title: Language.inst.ENABLE_BOTTOM_NAV_BAR,
              subtitle: Language.inst.ENABLE_BOTTOM_NAV_BAR_SUBTITLE,
              value: SettingsController.inst.enableBottomNavBar.value,
              onChanged: (p0) => SettingsController.inst.save(enableBottomNavBar: !p0),
            ),
          ),
          Obx(
            () => CustomSwitchListTile(
              enabled: SettingsController.inst.enableBottomNavBar.value,
              icon: Broken.slider_horizontal,
              title: Language.inst.ENABLE_SCROLLING_NAVIGATION,
              subtitle: Language.inst.ENABLE_SCROLLING_NAVIGATION_SUBTITLE,
              value: SettingsController.inst.enableScrollingNavigation.value,
              onChanged: (p0) => SettingsController.inst.save(enableScrollingNavigation: !p0),
            ),
          ),
          Obx(
            () => CustomSwitchListTile(
              icon: Broken.video_square,
              title: Language.inst.USE_YOUTUBE_MINIPLAYER,
              value: SettingsController.inst.useYoutubeMiniplayer.value,
              onChanged: (p0) => SettingsController.inst.save(useYoutubeMiniplayer: !p0),
            ),
          ),
          Obx(
            () => CustomSwitchListTile(
              icon: Broken.folder_open,
              title: Language.inst.ENABLE_FOLDERS_HIERARCHY,
              value: SettingsController.inst.enableFoldersHierarchy.value,
              onChanged: (p0) {
                SettingsController.inst.save(enableFoldersHierarchy: !p0);
                Folders.inst.isHome.value = true;
                Folders.inst.isInside.value = false;
              },
            ),
          ),
          Obx(
            () => CustomListTile(
              icon: Broken.receipt_1,
              title: Language.inst.DEFAULT_LIBRARY_TAB,
              trailingText: SettingsController.inst.autoLibraryTab.value ? Language.inst.AUTO : SettingsController.inst.selectedLibraryTab.value.toText,
              onTap: () => Get.dialog(
                CustomBlurryDialog(
                  title: Language.inst.DEFAULT_LIBRARY_TAB,
                  actions: [
                    ElevatedButton(
                      onPressed: () => Get.close(1),
                      child: Text(Language.inst.DONE),
                    ),
                  ],
                  child: SizedBox(
                    width: Get.width,
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(4.0),
                          child: Obx(
                            () => ListTileWithCheckMark(
                              title: Language.inst.AUTO,
                              icon: Broken.recovery_convert,
                              onTap: () => SettingsController.inst.save(autoLibraryTab: true),
                              active: SettingsController.inst.autoLibraryTab.value,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        ...SettingsController.inst.libraryTabs
                            .asMap()
                            .entries
                            .map(
                              (e) => Obx(
                                () => Container(
                                  margin: const EdgeInsets.all(4.0),
                                  child: ListTileWithCheckMark(
                                    title: "${e.key + 1}. ${e.value.toEnum.toText}",
                                    icon: e.value.toEnum.toIcon,
                                    onTap: () {
                                      SettingsController.inst.save(selectedLibraryTab: e.value.toEnum);
                                      SettingsController.inst.save(staticLibraryTab: e.value.toEnum);
                                      SettingsController.inst.save(autoLibraryTab: false);
                                    },
                                    active: SettingsController.inst.selectedLibraryTab.value == e.value.toEnum,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Obx(
            () {
              return CustomListTile(
                icon: Broken.color_swatch,
                title: Language.inst.LIBRARY_TABS,
                trailingText: "${SettingsController.inst.libraryTabs.length}",
                onTap: () => Get.dialog(
                  CustomBlurryDialog(
                    title: Language.inst.LIBRARY_TABS,
                    actions: [
                      ElevatedButton(
                        onPressed: () => Get.close(1),
                        child: Text(Language.inst.DONE),
                      ),
                    ],
                    child: Obx(
                      () {
                        final subList = <String>[].obs;
                        kLibraryTabsStock.toList().forEach((element) {
                          if (!SettingsController.inst.libraryTabs.contains(element)) {
                            subList.add(element);
                          }
                        });

                        return SizedBox(
                          width: Get.width,
                          child: Column(children: [
                            Text(
                              Language.inst.LIBRARY_TABS_REORDER,
                              style: context.textTheme.displayMedium,
                            ),
                            const SizedBox(height: 12.0),
                            SizedBox(
                              width: Get.width,
                              height: Get.height / 2.5,
                              child: NamidaListView(
                                padding: EdgeInsets.zero,
                                itemExtents: null,
                                itemCount: SettingsController.inst.libraryTabs.length,
                                itemBuilder: (context, i) {
                                  final tab = SettingsController.inst.libraryTabs[i];
                                  return Column(
                                    key: ValueKey(i),
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.all(4.0),
                                        child: ListTileWithCheckMark(
                                          title: "${i + 1}. ${tab.toEnum.toText}",
                                          icon: tab.toEnum.toIcon,
                                          onTap: () {
                                            if (SettingsController.inst.libraryTabs.length > 3) {
                                              SettingsController.inst.removeFromList(libraryTab1: tab);
                                              SettingsController.inst.save(selectedLibraryTab: SettingsController.inst.libraryTabs[0].toEnum);
                                            } else {
                                              Get.snackbar(Language.inst.AT_LEAST_THREE_TABS, Language.inst.AT_LEAST_THREE_TABS_SUBTITLE);
                                            }
                                          },
                                          active: SettingsController.inst.libraryTabs.contains(tab),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                                onReorder: (oldIndex, newIndex) {
                                  if (newIndex > oldIndex) {
                                    newIndex -= 1;
                                  }
                                  final item = SettingsController.inst.libraryTabs.elementAt(oldIndex);
                                  SettingsController.inst.removeFromList(
                                    libraryTab1: item,
                                  );
                                  SettingsController.inst.insertInList(newIndex, libraryTab1: item);
                                },
                              ),
                            ),
                            const NamidaContainerDivider(height: 4.0),
                            const SizedBox(height: 8.0),
                            ...subList
                                .asMap()
                                .entries
                                .map(
                                  (e) => Column(
                                    key: UniqueKey(),
                                    children: [
                                      ListTileWithCheckMark(
                                        title: "${e.key + 1}. ${e.value.toEnum.toText}",
                                        icon: e.value.toEnum.toIcon,
                                        onTap: () => SettingsController.inst.save(libraryTabs: [e.value]),
                                        active: SettingsController.inst.libraryTabs.contains(e.value),
                                      ),
                                      const SizedBox(height: 8.0),
                                    ],
                                  ),
                                )
                                .toList(),
                          ]),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
          Obx(
            () => CustomListTile(
              icon: Broken.filter_search,
              title: Language.inst.FILTER_TRACKS_BY,
              trailingText: "${SettingsController.inst.trackSearchFilter.length}",
              onTap: () => Get.dialog(
                Obx(
                  () {
                    return CustomBlurryDialog(
                      title: Language.inst.FILTER_TRACKS_BY,
                      actions: [
                        IconButton(
                          icon: const Icon(Broken.refresh),
                          tooltip: Language.inst.RESTORE_DEFAULTS,
                          onPressed: () {
                            SettingsController.inst.removeFromList(trackSearchFilterAll: [
                              'title',
                              'album',
                              'albumartist',
                              'artist',
                              'genre',
                              'composer',
                              'year',
                            ]);

                            SettingsController.inst.save(trackSearchFilter: ['title', 'artist', 'album']);
                          },
                        ),
                        ElevatedButton(
                          onPressed: () => Get.close(1),
                          child: Text(Language.inst.SAVE),
                        ),
                      ],
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 12.0),
                            ListTileWithCheckMark(
                              title: Language.inst.TITLE,
                              onTap: () {
                                _trackFilterOnTap(TrackSearchFilter.title);
                              },
                              active: SettingsController.inst.trackSearchFilter.contains('title'),
                            ),
                            const SizedBox(height: 12.0),
                            ListTileWithCheckMark(
                              title: Language.inst.ALBUM,
                              onTap: () {
                                _trackFilterOnTap(TrackSearchFilter.album);
                              },
                              active: SettingsController.inst.trackSearchFilter.contains('album'),
                            ),
                            const SizedBox(height: 12.0),
                            ListTileWithCheckMark(
                              title: Language.inst.ALBUM_ARTIST,
                              onTap: () {
                                _trackFilterOnTap(TrackSearchFilter.albumartist);
                              },
                              active: SettingsController.inst.trackSearchFilter.contains('albumartist'),
                            ),
                            const SizedBox(height: 12.0),
                            ListTileWithCheckMark(
                              title: Language.inst.ARTIST,
                              onTap: () {
                                _trackFilterOnTap(TrackSearchFilter.artist);
                              },
                              active: SettingsController.inst.trackSearchFilter.contains('artist'),
                            ),
                            const SizedBox(height: 12.0),
                            ListTileWithCheckMark(
                              title: Language.inst.GENRE,
                              onTap: () {
                                _trackFilterOnTap(TrackSearchFilter.genre);
                              },
                              active: SettingsController.inst.trackSearchFilter.contains('genre'),
                            ),
                            const SizedBox(height: 12.0),
                            ListTileWithCheckMark(
                              title: Language.inst.COMPOSER,
                              onTap: () {
                                _trackFilterOnTap(TrackSearchFilter.composer);
                              },
                              active: SettingsController.inst.trackSearchFilter.contains('composer'),
                            ),
                            const SizedBox(height: 12.0),
                            ListTileWithCheckMark(
                              title: Language.inst.YEAR,
                              onTap: () => _trackFilterOnTap(TrackSearchFilter.year),
                              active: SettingsController.inst.trackSearchFilter.contains('year'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Obx(
            () => CustomSwitchListTile(
              icon: Broken.document_filter,
              title: Language.inst.ENABLE_SEARCH_CLEANUP,
              subtitle: Language.inst.ENABLE_SEARCH_CLEANUP_SUBTITLE,
              value: SettingsController.inst.enableSearchCleanup.value,
              onChanged: (p0) => SettingsController.inst.save(enableSearchCleanup: !p0),
            ),
          ),
          CustomListTile(
            icon: Broken.sound,
            title: Language.inst.GENERATE_ALL_WAVEFORM_DATA,
            trailing: Obx(
              () => Column(
                children: [
                  Text("${Indexer.inst.waveformsInStorage.value}/${allTracksInLibrary.length}"),
                  if (WaveformController.inst.generatingAllWaveforms.value) const LoadingIndicator(),
                ],
              ),
            ),
            onTap: () async {
              if (WaveformController.inst.generatingAllWaveforms.value) {
                await Get.dialog(
                  CustomBlurryDialog(
                    title: Language.inst.NOTE,
                    bodyText: Language.inst.FORCE_STOP_WAVEFORM_GENERATION,
                    actions: [
                      const CancelButton(),
                      ElevatedButton(
                        onPressed: () {
                          WaveformController.inst.generatingAllWaveforms.value = false;
                          Get.close(1);
                        },
                        child: Text(Language.inst.STOP),
                      ),
                    ],
                  ),
                );
              } else {
                await Get.dialog(
                  CustomBlurryDialog(
                    title: Language.inst.NOTE,
                    bodyText: Language.inst.GENERATE_ALL_WAVEFORM_DATA_SUBTITLE
                        .replaceFirst('_WAVEFORM_CURRENT_LENGTH_', '${Indexer.inst.waveformsInStorage.value}')
                        .replaceFirst('_WAVEFORM_TOTAL_LENGTH_', '${allTracksInLibrary.length}'),
                    actions: [
                      const CancelButton(),
                      ElevatedButton(
                        onPressed: () {
                          WaveformController.inst.generateAllWaveforms();
                          Get.close(1);
                        },
                        child: Text(Language.inst.GENERATE),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          CustomListTile(
            icon: Broken.colorfilter,
            title: Language.inst.EXTRACT_ALL_COLOR_PALETTES,
            trailing: Obx(
              () => Column(
                children: [
                  Text("${Indexer.inst.colorPalettesInStorage.value}/${Indexer.inst.artworksInStorage.value.toString()}"),
                  if (CurrentColor.inst.generatingAllColorPalettes.value) const LoadingIndicator(),
                ],
              ),
            ),
            onTap: () async {
              if (CurrentColor.inst.generatingAllColorPalettes.value) {
                await Get.dialog(
                  CustomBlurryDialog(
                    title: Language.inst.NOTE,
                    bodyText: Language.inst.FORCE_STOP_COLOR_PALETTE_GENERATION,
                    actions: [
                      const CancelButton(),
                      ElevatedButton(
                        onPressed: () {
                          CurrentColor.inst.generatingAllColorPalettes.value = false;
                          Get.close(1);
                        },
                        child: Text(Language.inst.STOP),
                      ),
                    ],
                  ),
                );
              } else {
                await Get.dialog(
                  CustomBlurryDialog(
                    title: Language.inst.NOTE,
                    bodyText: Language.inst.EXTRACT_ALL_COLOR_PALETTES_SUBTITLE
                        .replaceFirst('_REMAINING_COLOR_PALETTES_', '${allTracksInLibrary.length - Indexer.inst.colorPalettesInStorage.value}'),
                    actions: [
                      const CancelButton(),
                      ElevatedButton(
                        onPressed: () {
                          CurrentColor.inst.generateAllColorPalettes();
                          Get.close(1);
                        },
                        child: Text(Language.inst.EXTRACT),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _trackFilterOnTap(TrackSearchFilter filter) {
    String type = '';
    switch (filter) {
      case TrackSearchFilter.title:
        type = 'title';
        break;
      case TrackSearchFilter.album:
        type = 'album';
        break;
      case TrackSearchFilter.albumartist:
        type = 'albumartist';
        break;
      case TrackSearchFilter.artist:
        type = 'artist';
        break;

      case TrackSearchFilter.genre:
        type = 'genre';
        break;
      case TrackSearchFilter.composer:
        type = 'composer';
        break;
      case TrackSearchFilter.year:
        type = 'year';
        break;
      default:
        null;
    }

    final canRemove = SettingsController.inst.trackSearchFilter.length > 1;

    if (SettingsController.inst.trackSearchFilter.contains(type)) {
      if (canRemove) {
        SettingsController.inst.removeFromList(trackSearchFilter1: type);
      } else {
        Get.snackbar(Language.inst.AT_LEAST_ONE_FILTER, Language.inst.AT_LEAST_ONE_FILTER_SUBTITLE);
      }
    } else {
      SettingsController.inst.save(trackSearchFilter: [type]);
    }
  }
}

class LoadingIndicator extends StatefulWidget {
  final Color? circleColor;
  final double? width;
  final double? height;
  final double? maxWidth;
  final double? maxHeight;
  final int? durationInMillisecond;
  const LoadingIndicator({super.key, this.circleColor, this.width, this.height, this.durationInMillisecond, this.maxWidth, this.maxHeight});

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator> {
  late Timer timer;
  Rx<Alignment> alignment = Alignment.centerLeft.obs;
  @override
  void initState() {
    timer = Timer.periodic(Duration(milliseconds: widget.durationInMillisecond ?? 350), (Timer timer) {
      if (alignment.value == Alignment.centerLeft) {
        alignment.value = Alignment.centerRight;
      } else {
        alignment.value = Alignment.centerLeft;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.maxWidth ?? 20.0,
      height: widget.maxHeight ?? 5.0,
      child: Obx(
        () => AnimatedAlign(
          duration: Duration(milliseconds: widget.durationInMillisecond ?? 400),
          curve: Curves.easeOutSine,
          alignment: alignment.value,
          child: Container(
            width: widget.width ?? 5.0,
            height: widget.height ?? 5.0,
            decoration: BoxDecoration(
              color: widget.circleColor ?? Get.textTheme.displayMedium?.color,
              borderRadius: BorderRadius.circular(30.0.multipliedRadius),
              // boxShadow: [
              //   BoxShadow(color: Colors.black.withAlpha(100), spreadRadius: 1, blurRadius: 4, offset: Offset(0, 2)),
              // ],
            ),
          ),
        ),
      ),
    );
  }
}