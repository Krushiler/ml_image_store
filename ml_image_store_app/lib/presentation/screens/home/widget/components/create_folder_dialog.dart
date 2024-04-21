import 'package:flutter/material.dart';
import 'package:ml_image_store/model/folder/folder.dart';
import 'package:ml_image_store_app/presentation/style/kit/gap.dart';
import 'package:ml_image_store_app/presentation/style/theme/app_context_extension.dart';

class CreateFolderDialog extends StatefulWidget {
  const CreateFolderDialog({super.key});

  @override
  State<CreateFolderDialog> createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends State<CreateFolderDialog> {
  final TextEditingController controller = TextEditingController();
  LabelType type = LabelType.bbox;

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
        DropdownButtonFormField<LabelType>(
          decoration: const InputDecoration(labelText: 'Type'),
          value: type,
          onChanged: (value) {
            setState(() {
              type = value ?? type;
            });
          },
          items: LabelType.values.map((e) => DropdownMenuItem<LabelType>(value: e, child: Text(e.name))).toList(),
        ),
        Gap.md,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            TextButton(
              onPressed: controller.text.isNotEmpty
                  ? () {
                      Navigator.of(context).pop(CreateFolderResult(controller.text, type));
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

class CreateFolderResult {
  final String name;
  final LabelType type;

  CreateFolderResult(this.name, this.type);
}
