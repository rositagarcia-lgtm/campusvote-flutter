import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/errors/error_mapper.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/widgets/app_appbar.dart';
import '../../../core/widgets/app_empty_view.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/app_motion.dart';
import '../data/certificates_repository.dart';

/// `/certificados` — certificados de feria del usuario. Cada uno se descarga
/// en PDF y se abre con el menú de compartir (guardar, WhatsApp, imprimir…).
class MyCertificatesPage extends ConsumerWidget {
  const MyCertificatesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final certificates = ref.watch(myCertificatesProvider);
    Future<void> reload() => ref.refresh(myCertificatesProvider.future);
    return Scaffold(
      appBar: buildCampusVoteAppBar(context, title: 'Mis certificados'),
      body: RefreshIndicator(
        onRefresh: reload,
        child: certificates.when(
          loading: () => const AppLoader(),
          error: (error, _) => AppErrorView(
            message: mapExceptionToFailure(error).message,
            onRetry: reload,
          ),
          data: (items) => items.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    AppEmptyView(
                      icon: PhosphorIconsRegular.certificate,
                      overline: 'CERTIFICADOS',
                      title: 'Aún no tienes certificados',
                      message: 'Cuando la feria termine y la institución '
                          'emita los certificados, aparecerán aquí.',
                    ),
                  ],
                )
              : ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.l),
                  children: [
                    for (var i = 0; i < items.length; i++)
                      AppMotion.reveal(i, _CertificateCard(certificate: items[i])),
                  ],
                ),
        ),
      ),
    );
  }
}

class _CertificateCard extends ConsumerStatefulWidget {
  const _CertificateCard({required this.certificate});

  final MyCertificate certificate;

  @override
  ConsumerState<_CertificateCard> createState() => _CertificateCardState();
}

class _CertificateCardState extends ConsumerState<_CertificateCard> {
  bool _busy = false;

  Future<void> _download() async {
    setState(() => _busy = true);
    try {
      final file = await ref
          .read(certificatesRepositoryProvider)
          .download(widget.certificate);
      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf')],
        subject: 'Certificado · ${widget.certificate.fairName}',
      ));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(mapExceptionToFailure(error).message),
      ));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final c = widget.certificate;
    final color = c.winner ? const Color(0xFFD4A017) : scheme.primary;
    final date = c.issuedAt?.toLocal();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: AppRadii.rLarge,
          border: Border.all(color: color.withValues(alpha: 0.45)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  c.winner
                      ? PhosphorIconsFill.trophy
                      : PhosphorIconsFill.certificate,
                  color: color,
                  size: 32,
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.winner
                            ? 'Ganador${c.category == null ? '' : ' · ${c.category}'}'
                            : 'Participación',
                        style: theme.textTheme.labelMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      Text(c.projectName,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800)),
                      Text(
                        [
                          c.fairName,
                          if (date != null)
                            '${date.day}/${date.month}/${date.year}',
                        ].join(' · '),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            FilledButton.icon(
              onPressed: _busy ? null : _download,
              icon: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(PhosphorIconsRegular.downloadSimple),
              label: Text(_busy ? 'Descargando…' : 'Descargar PDF'),
            ),
          ],
        ),
      ),
    );
  }
}
