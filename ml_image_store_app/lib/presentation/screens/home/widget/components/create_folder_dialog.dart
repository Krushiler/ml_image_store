import 'package:flutter/material.dart';
import 'package:ml_image_store_app/presentation/style/kit/gap.dart';
import 'package:ml_image_store_app/presentation/style/theme/app_context_extension.dart';

class CreateFolderDialog extends StatefulWidget {
  const CreateFolderDialog({super.key});

  @override
  State<CreateFolderDialog> createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends State<CreateFolderDialog> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Create folder', style: context.theme.textTheme.titleMedium),
        Gap.md,
        TextFormField(
          decoration: const InputDecoration(labelText: 'Name'),
          controller: controller,
          onChanged: (_) {
            setState(() {});
          },
        ),
        Gap.md,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            TextButton(
              onPressed: controller.text.isNotEmpty
                  ? () {
                      Navigator.of(context).pop(controller.text);
                    }
                  : null,
              child: const Text('Create'),
            )
          ],
        )
      ],
    );
  }
}
