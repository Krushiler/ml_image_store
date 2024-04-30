import 'package:flutter/material.dart';
import 'package:ml_image_store_app/presentation/style/kit/gap.dart';
import 'package:ml_image_store_app/presentation/style/theme/app_context_extension.dart';
import 'package:ml_image_store/model/folder/folder.dart';

class DatasetDownloadDialog extends StatefulWidget {
  final LabelType labelType;

  const DatasetDownloadDialog({super.key, required this.labelType});

  @override
  State<DatasetDownloadDialog> createState() => _DatasetDownloadDialogState();
}

class _DatasetDownloadDialogState extends State<DatasetDownloadDialog> {
  final widthController = TextEditingController();
  final heightController = TextEditingController();
  bool maintainAspectRatio = true;
  DatasetType datasetType = DatasetType.fullJson;
  bool linkHeight = true;

  @override
  Widget build(BuildContext context) {
    if (linkHeight) {
      heightController.text = widthController.text;
    }
    return Column(
      children: [
        Text('Download Dataset', style: context.theme.textTheme.titleMedium),
        Gap.md,
        DropdownButtonFormField<DatasetType>(
          decoration: const InputDecoration(labelText: 'Type'),
          value: datasetType,
          onChanged: (value) {
            setState(() {
              datasetType = value ?? datasetType;
            });
          },
          items: DatasetType.values
              .where((element) => element.labelTypes.contains(widget.labelType))
              .map(
                (e) => DropdownMenuItem<DatasetType>(value: e, child: Text(e.representation)),
              )
              .toList(),
        ),
        Gap.md,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: TextFormField(
                controller: widthController,
                decoration: const InputDecoration(labelText: 'Width'),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
            ),
            Gap.md,
            IconButton(
              onPressed: () {
                setState(() {
                  linkHeight = !linkHeight;
                });
              },
              icon: Icon(
                linkHeight ? Icons.link : Icons.link_off,
                color: context.colors.foreground,
              ),
            ),
            Gap.md,
            Expanded(
              child: TextFormField(
                controller: heightController,
                decoration: const InputDecoration(labelText: 'Height'),
                readOnly: linkHeight,
                enabled: !linkHeight,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        Gap.md,
        Row(
          children: [
            Text('Maintain Aspect Ratio', style: context.theme.textTheme.titleMedium),
            Gap.md,
            Checkbox(
              value: maintainAspectRatio,
              onChanged: (value) => setState(() => maintainAspectRatio = value ?? maintainAspectRatio),
            )
          ],
        ),
        Gap.md,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            TextButton(
              onPressed: int.tryParse(widthController.text) != null && int.tryParse(heightController.text) != null
                  ? () {
                      Navigator.of(context).pop(
                        DatasetDownloadResult(
                          datasetType: datasetType,
                          width: int.parse(widthController.text),
                          height: int.parse(heightController.text),
                          maintainAspectRatio: maintainAspectRatio,
                        ),
                      );
                    }
                  : null,
              child: const Text('Download'),
            ),
          ],
        ),
      ],
    );
  }
}

enum DatasetType {
  fullJson('fullJson', 'Json', [LabelType.bbox, LabelType.polygon]),
  yolo('yolo', 'YOLO', [LabelType.bbox]),
  coco('coco', 'COCO', [LabelType.bbox, LabelType.polygon]),
  csv('csv', 'CSV', [LabelType.bbox]),
  ;

  final String name;
  final String representation;
  final List<LabelType> labelTypes;

  const DatasetType(this.name, this.representation, this.labelTypes);
}

class DatasetDownloadResult {
  final DatasetType datasetType;
  final int width;
  final int height;
  final bool maintainAspectRatio;

  DatasetDownloadResult({
    required this.datasetType,
    required this.width,
    required this.height,
    required this.maintainAspectRatio,
  });
}
