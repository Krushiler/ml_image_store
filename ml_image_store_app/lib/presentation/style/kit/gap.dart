import 'package:flutter/material.dart';

import 'dimens.dart';

class Gap {
  const Gap._();

  static get xxs => const SizedBox(height: Dimens.xxs, width: Dimens.xxs);

  static get xs => const SizedBox(height: Dimens.xs, width: Dimens.xs);

  static get sm => const SizedBox(height: Dimens.sm, width: Dimens.sm);

  static get smd => const SizedBox(height: Dimens.smd, width: Dimens.smd);

  static get md => const SizedBox(height: Dimens.md, width: Dimens.md);

  static get lg => const SizedBox(height: Dimens.lg, width: Dimens.lg);

  static get xl => const SizedBox(height: Dimens.xl, width: Dimens.xl);

  static get xxl => const SizedBox(height: Dimens.xxl, width: Dimens.xxl);

  static systemBottom(BuildContext context) => SizedBox(height: Dimens.system(context).bottom);
}