import 'dart:ui' as ui;

import 'package:campusvote_flutter/core/widgets/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('el logo PNG se carga y se pinta sin alterar su tamaño',
      (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: RepaintBoundary(
            key: key,
            child: AppLogo.asset(size: 96),
          ),
        ),
      ),
    ));
    await tester.runAsync(() => precacheImage(
          const AssetImage(kCampusVoteLogoAsset),
          tester.element(find.byType(AppLogo)),
        ));
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('CV'), findsNothing);
    expect(tester.getSize(find.byType(AppLogo)), const Size(96, 96));
    final imageWidget = tester.widget<Image>(find.byType(Image));
    expect(imageWidget.image, isA<AssetImage>());
    expect((imageWidget.image as AssetImage).assetName, kCampusVoteLogoAsset);
    expect(imageWidget.fit, BoxFit.contain);

    final visiblePixels = await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      image.dispose();
      final pixels = bytes!.buffer.asUint8List();
      return Iterable.generate(pixels.length ~/ 4)
          .any((index) => pixels[index * 4 + 3] > 0);
    });
    expect(visiblePixels, isTrue);

    expect(tester.takeException(), isNull);
  });
}
