import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:revanced_manager/app/app.locator.dart';
import 'package:revanced_manager/ui/views/home/home_viewmodel.dart';
import 'package:revanced_manager/ui/widgets/homeView/installed_apps_card.dart';
import 'package:revanced_manager/ui/widgets/homeView/latest_commit_card.dart';
import 'package:revanced_manager/ui/widgets/shared/custom_sliver_app_bar.dart';
import 'package:stacked/stacked.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      disposeViewModel: false,
      fireOnViewModelReadyOnce: true,
      onViewModelReady: (model) => model.initialize(context),
      viewModelBuilder: () => locator<HomeViewModel>(),
      builder: (context, model, child) => Scaffold(
        body: RefreshIndicator(
          onRefresh: () => model.forceRefresh(context),
          child: CustomScrollView(
            slivers: <Widget>[
              CustomSliverAppBar(
                isMainView: true,
                title: I18nText(
                  'homeView.widgetTitle',
                  child: Text(
                    '',
                    style: GoogleFonts.inter(
                      color: Theme.of(context).textTheme.titleLarge!.color,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate.fixed(
                    <Widget>[
                      I18nText(
                        'homeView.updatesSubtitle',
                        child: Text(
                          '',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(height: 10),
                      LatestCommitCard(model: model, parentContext: context),
                      const SizedBox(height: 23),
                      I18nText(
                        'homeView.patchedSubtitle',
                        child: Text(
                          '',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(height: 10),
                      InstalledAppsCard(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
