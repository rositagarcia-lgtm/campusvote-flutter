import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';
import 'app_palette.dart';

/// Ancho máximo de los flujos de acceso y formularios.
const double kFormMaxWidth = 480;

/// Ancho máximo de listas y paneles.
const double kListMaxWidth = 640;

/// Contenido centrado con ancho máximo, para pantallas que no necesitan
/// desplazamiento (confirmaciones, diálogos de contenido corto).
class ConstrainedContent extends StatelessWidget {
  const ConstrainedContent({
    super.key,
    required this.child,
    this.maxWidth = kFormMaxWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Cuerpo desplazable de página: centra el contenido, limita el ancho y
/// respeta el margen inferior del sistema.
///
/// [physics] debe ser `AlwaysScrollableScrollPhysics` cuando el cuerpo cuelga
/// de un `RefreshIndicator` con poco contenido.
class PageScrollBody extends StatelessWidget {
  const PageScrollBody({
    super.key,
    required this.child,
    this.maxWidth = kListMaxWidth,
    this.padding,
    this.physics,
    this.bottomInset = true,
  });

  final Widget child;
  final double maxWidth;

  /// Padding explícito; si es nulo se aplica el padding estándar.
  final EdgeInsetsGeometry? padding;

  final ScrollPhysics? physics;

  /// Suma el margen inferior del sistema al padding del pie.
  final bool bottomInset;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: physics ?? const ClampingScrollPhysics(),
      padding: padding ??
          EdgeInsets.fromLTRB(
            AppSpacing.l,
            AppSpacing.l,
            AppSpacing.l,
            bottomInset
                ? AppSpacing.xxl + MediaQuery.paddingOf(context).bottom
                : AppSpacing.xl,
          ),
      child: ConstrainedContent(maxWidth: maxWidth, child: child),
    );
  }
}

/// Barra de acción fija al pie: separador fino, margen del sistema y zona
/// segura inferior. Aloja la acción principal de la pantalla.
class ActionFooter extends StatelessWidget {
  const ActionFooter({super.key, required this.child, this.divider = true});

  final Widget child;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (divider)
            Divider(height: 1, thickness: 1, color: appBorder(isDark)),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: child,
          ),
        ],
      ),
    );
  }
}
