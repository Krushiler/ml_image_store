import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ml_image_store_app/presentation/navigation/navigation.dart';
import 'package:ml_image_store_app/presentation/screens/home/bloc/home_bloc.dart';
import 'package:ml_image_store_app/presentation/screens/home/widget/components/create_folder_dialog.dart';
import 'package:ml_image_store_app/presentation/screens/home/widget/components/folder_list_item.dart';
import 'package:ml_image_store_app/presentation/style/kit/dimens.dart';
import 'package:ml_image_store_app/presentation/style/theme/app_context_extension.dart';
import 'package:ml_image_store_app/presentation/util/snackbar_util.dart';
import 'package:ml_image_store_app/presentation/widgets/dialog/app_dialog.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return BlocListener<HomeBloc, HomeState>(
          listenWhen: (_, curr) => curr.error != null,
          listener: (context, state) {
            context.showErrorSnackBar(state.error);
          },
          child: Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                final result = await context.showAppDialog<CreateFolderResult>(child: const CreateFolderDialog());
                if (result != null && context.mounted) {
                  context.read<HomeBloc>().add(HomeEvent.createFolderRequested(result.name, result.type));
                }
              },
              child: Icon(
                Icons.add,
                color: context.colors.background,
              ),
            ),
            appBar: AppBar(
              title: const Text('Home'),
              actions: [
                IconButton(
                  onPressed: () {
                    context.read<HomeBloc>().add(const HomeEvent.logoutRequested());
                  },
                  icon: const Icon(Icons.logout),
                )
              ],
            ),
            body: Stack(
              children: [
                GridView.builder(
                  padding: const EdgeInsets.all(Dimens.md),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 140,
                    mainAxisSpacing: Dimens.md,
                    crossAxisSpacing: Dimens.md,
                  ),
                  itemCount: state.folders.length,
                  itemBuilder: (context, index) => FolderListItem(
                    folder: state.folders[index],
                    onPressed: () {
                      context.navigation.navigateToFolder(state.folders[index].id);
                    },
                    onDeletePressed: () {
                      context.read<HomeBloc>().add(HomeEvent.deleteFolderRequested(state.folders[index].id));
                    },
                  ),
                ),
                if (state.isLoading) const Center(child: CircularProgressIndicator())
              ],
            ),
          ),
        );
      },
    );
  }
}
