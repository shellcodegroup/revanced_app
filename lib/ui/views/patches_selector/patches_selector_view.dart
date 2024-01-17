import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:revanced_manager/app/app.locator.dart';
import 'package:revanced_manager/services/manager_api.dart';
import 'package:revanced_manager/ui/views/patches_selector/patches_selector_viewmodel.dart';
import 'package:revanced_manager/ui/widgets/shared/search_bar.dart';
import 'package:stacked/stacked.dart';

class PatchesSelectorView extends StatefulWidget {
  const PatchesSelectorView({super.key});

  @override
  State<PatchesSelectorView> createState() => _PatchesSelectorViewState();
}

class _PatchesSelectorViewState extends State<PatchesSelectorView> {
  String _query = '';
  final _managerAPI = locator<ManagerAPI>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_managerAPI.isPatchesChangeEnabled() &&
          _managerAPI.showPatchesChangeWarning()) {
        _managerAPI.showPatchesChangeWarningDialog(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PatchesSelectorViewModel>.reactive(
      onViewModelReady: (model) => model.initialize(),
      viewModelBuilder: () => PatchesSelectorViewModel(),
      builder: (context, model, child) => Scaffold(
        floatingActionButton: Visibility(
          visible: model.patches.isNotEmpty,
          child: FloatingActionButton.extended(
            label: Row(
              children: <Widget>[
                I18nText('patchesSelectorView.doneButton'),
                Text(' (${model.selectedPatches.length})'),
              ],
            ),
            icon: const Icon(Icons.check),
            onPressed: () {
              if (!model.areRequiredOptionsNull(context)) {
                model.selectPatches();
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: true,
              title: I18nText(
                'patchesSelectorView.viewTitle',
              ),
              titleTextStyle: TextStyle(
                fontSize: 22.0,
                color: Theme.of(context).textTheme.titleLarge!.color,
              ),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).textTheme.titleLarge!.color,
                ),
                onPressed: () {
                  model.resetSelection();
                  Navigator.of(context).pop();
                },
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.tertiary.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    model.patchesVersion!,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.titleLarge!.color,
                    ),
                  ),
                ),
                PopupMenuButton(
                  onSelected: (value) {
                    model.onMenuSelection(value, context);
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                    PopupMenuItem(
                      value: 0,
                      child: I18nText(
                        'patchesSelectorView.loadPatchesSelection',
                      ),
                    ),
                  ],
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(66.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 12.0,
                  ),
                  child: SearchBar(
                    hintText: FlutterI18n.translate(
                      context,
                      'patchesSelectorView.searchBarHint',
                    ),
                    onQueryChanged: (searchQuery) {
                      setState(() {
                        _query = searchQuery;
                      });
                    },
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: model.patches.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: I18nText(
                          'patchesSelectorView.noPatchesFound',
                          child: Text(
                            '',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    )
                  : Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12.0).copyWith(
                        bottom: MediaQuery.viewPaddingOf(context).bottom + 8.0,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              ActionChip(
                                label: I18nText('patchesSelectorView.default'),
                                tooltip: FlutterI18n.translate(
                                  context,
                                  'patchesSelectorView.defaultTooltip',
                                ),
                                onPressed: () {
                                  if (_managerAPI.isPatchesChangeEnabled()) {
                                    model.selectDefaultPatches();
                                  } else {
                                    model.showPatchesChangeDialog(context);
                                  }
                                },
                              ),
                              const SizedBox(width: 8),
                              ActionChip(
                                label: I18nText('patchesSelectorView.none'),
                                tooltip: FlutterI18n.translate(
                                  context,
                                  'patchesSelectorView.noneTooltip',
                                ),
                                onPressed: () {
                                  if (_managerAPI.isPatchesChangeEnabled()) {
                                    model.clearPatches();
                                  } else {
                                    model.showPatchesChangeDialog(context);
                                  }
                                },
                              ),
                            ],
                          ),
                          if (model
                              .getQueriedPatches(_query)
                              .any((patch) => model.isPatchNew(patch)))
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                model.getPatchCategory(
                                  context,
                                  'patchesSelectorView.newPatches',
                                ),
                                ...model.getQueriedPatches(_query).map((patch) {
                                  if (model.isPatchNew(patch)) {
                                    return model.getPatchItem(context, patch);
                                  } else {
                                    return Container();
                                  }
                                }),
                                if (model.getQueriedPatches(_query).any(
                                      (patch) =>
                                          !model.isPatchNew(patch) &&
                                          patch.compatiblePackages.isNotEmpty,
                                    ))
                                  model.getPatchCategory(
                                    context,
                                    'patchesSelectorView.patches',
                                  ),
                              ],
                            ),
                          ...model.getQueriedPatches(_query).map(
                            (patch) {
                              if (patch.compatiblePackages.isNotEmpty &&
                                  !model.isPatchNew(patch)) {
                                return model.getPatchItem(context, patch);
                              } else {
                                return Container();
                              }
                            },
                          ),
                          if (model
                              .getQueriedPatches(_query)
                              .any((patch) => patch.compatiblePackages.isEmpty))
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                model.getPatchCategory(
                                  context,
                                  'patchesSelectorView.universalPatches',
                                ),
                                ...model.getQueriedPatches(_query).map((patch) {
                                  if (patch.compatiblePackages.isEmpty &&
                                      !model.isPatchNew(patch)) {
                                    return model.getPatchItem(context, patch);
                                  } else {
                                    return Container();
                                  }
                                }),
                              ],
                            ),
                          const SizedBox(height: 70.0),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
