import 'package:campusvote_flutter/core/session/clear_account_state.dart';
import 'package:campusvote_flutter/features/jury/data/models/jury_models.dart';
import 'package:campusvote_flutter/features/jury/presentation/providers/fairs/jury_fair_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

int buildCount = 0;

class _Dashboard extends JuryDashboardNotifier {
  @override
  Future<List<FairAssignmentModel>> build() async {
    buildCount++;
    return [];
  }
}

final _clearProvider = Provider<void Function()>((ref) => () => clearAccountState(ref));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('el cierre descarta el dashboard de la cuenta anterior', () async {
    buildCount = 0;
    final container = ProviderContainer(overrides: [
      juryDashboardProvider.overrideWith(_Dashboard.new),
    ]);
    addTearDown(container.dispose);
    final subscription = container.listen(juryDashboardProvider, (_, __) {});
    addTearDown(subscription.close);

    await container.read(juryDashboardProvider.future);
    expect(buildCount, 1);

    container.read(_clearProvider)();
    await container.read(juryDashboardProvider.future);
    expect(buildCount, 2);
  });
}
