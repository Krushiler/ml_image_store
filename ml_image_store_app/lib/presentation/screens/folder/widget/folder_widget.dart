import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ml_image_store/model/folder/folder.dart';
import 'package:ml_image_store_app/data/model/server_config.dart';
import 'package:ml_image_store_app/presentation/navigation/navigation.dart';
import 'package:ml_image_store_app/presentation/screens/folder/bloc/folder_bloc.dart';
import 'package:ml_image_store_app/presentation/screens/folder/widget/components/dataset_download_dialog.dart';
import 'package:ml_image_store_app/presentation/screens/folder/widget/components/image_list_item.dart';
import 'package:ml_image_store_app/presentation/style/kit/dimens.dart';
import 'package:ml_image_store_app/presentation/style/theme/app_context_extension.dart';
import 'package:ml_image_store_app/presentation/util/snackbar_util.dart';
import 'package:ml_image_store_app/presentation/widgets/dialog/app_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class FolderWidget extends StatefulWidget {
  const FolderWidget({super.key});

  @override
  State<FolderWidget> createState() => _FolderWidgetState();
}

class _FolderWidgetState extends State<FolderWidget> {
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      if (scrollController.position.extentAfter < 500) {
        context.read<FolderBloc>().add(const FolderEvent.loadMoreRequested());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FolderBloc, FolderState>(
      builder: (context, state) {
        return BlocListener<FolderBloc, FolderState>(
          listenWhen: (_, curr) => curr.error != null,
          listener: (context, state) {
            context.showErrorSnackBar(state.error);
          },
          child: Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                context.navigation.navigateToImageCreation(state.folderId);
              },
              child: Icon(
                Icons.add,
                color: context.colors.background,
              ),
            ),
            appBar: AppBar(
              // title: Text(state.folder?.name ?? 'Folder'),
              title: RichText(
                text: TextSpan(
                  style: context.theme.textTheme.titleLarge?.copyWith(
                    color: context.colors.background,
                    leadingDistribution: TextLeadingDistribution.even,
                  ),
                  children: [
                    TextSpan(text: state.folder?.name ?? 'Folder'),
                    if (state.folder?.type != null) TextSpan(text: ' | ${state.folder?.type.name}'),
                  ],
                ),
              ),
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
              ),
              actions: [
                if (state.folder != null)
                  PopupMenuButton(
                    icon: const Icon(Icons.download),
                    tooltip: 'Download',
                    offset: const Offset(0, 48),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('Full Json'),
                        onTap: () {
                          launchUrl(
                            Uri.parse('${context.read<ServerConfig>().baseUrl}/folders/${state.folder?.id}/download'),
                          );
                        },
                      ),
                      PopupMenuItem(
                        child: const Text('Dataset'),
                        onTap: () async {
                          final result = await context.showAppDialog<DatasetDownloadResult>(
                            child: DatasetDownloadDialog(labelType: state.folder?.type ?? LabelType.bbox),
                          );
                          if (result == null || !context.mounted) return;
                          launchUrl(
                            Uri.parse(
                              '${context.read<ServerConfig>().baseUrl}/folders/${state.folder?.id}/download'
                              '?type=${result.datasetType.name}'
                              '&width=${result.width}&height=${result.height}'
                              '&maintainAspect=${result.maintainAspectRatio}',
                            ),
                          );
                        },
                      ),
                    ],
                  ),
              ],
            ),
            body: Stack(
              children: [
                GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(Dimens.md),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 140,
                    mainAxisSpacing: Dimens.md,
                    crossAxisSpacing: Dimens.md,
                  ),
                  itemCount: state.isLoadingImages ? state.images.length + 1 : state.images.length,
                  itemBuilder: (context, index) {
                    if (index < state.images.length) {
                      return ImageListItem(
                        image: state.images[index],
                        onPressed: () {
                          context.navigation.navigateToImage(state.folderId, state.images[index].id);
                        },
                        onDeletePressed: () {
                          context.read<FolderBloc>().add(FolderEvent.deleteImageRequested(state.images[index].id));
                        },
                      );
                    } else {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimens.sm),
                          border: Border.all(color: context.colors.primary),
                        ),
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(),
                      );
                    }
                  },
                ),
                if (state.isDeletingImage) const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        );
      },
    );
  }
}
