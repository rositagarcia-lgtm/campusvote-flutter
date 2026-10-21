import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/branding/branding_controller.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/app_empty_view.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/app_motion.dart';
import '../../../core/widgets/app_status_chip.dart';
import '../../../core/widgets/organization_panel_app_bar.dart';
import '../../settings/presentation/settings_copy.dart';
import '../../notifications/presentation/widgets/notifications_bell.dart';
import '../data/student_projects_repository.dart';
import '../domain/student_project.dart';
import 'widgets/project_visuals.dart';

part 'student_projects/student_projects_overview.dart';
part 'student_projects/student_project_card.dart';
