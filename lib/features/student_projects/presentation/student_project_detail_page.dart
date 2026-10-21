import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_env.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_motion.dart';
import '../../../core/widgets/app_notice.dart';
import '../../../core/widgets/app_status_chip.dart';
import '../../../core/widgets/translatable_text.dart';
import '../../fair_audience/data/fair_audience_repository.dart';
import '../../fair_audience/domain/audience_models.dart';
import '../../fair_audience/presentation/rate_project_sheet.dart';
import '../../settings/presentation/settings_copy.dart';
import '../data/student_projects_repository.dart';
import '../domain/student_project.dart';
import 'widgets/project_visuals.dart';

part 'project_detail/student_project_detail_page.dart';
part 'project_detail/jury_reviews_page.dart';
part 'project_detail/student_project_detail_widgets.dart';
