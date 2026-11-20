// voting_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../state/jury_state.dart';
import 'voting_controller.dart';

/// Estado de votación + proyectos votables de la feria.
final votingFormProvider =
    StateNotifierProvider.family<VotingFormController, VotingFormState, String>(
        VotingFormController.new);