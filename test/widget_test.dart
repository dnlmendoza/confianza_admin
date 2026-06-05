import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/test.dart';
import 'package:confianza_admin/modulos/inventario/vista_inventario.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();

  setUpAll(() async {
    HttpOverrides.global = MockHttpOverrides();
    try {
      await Firebase.initializeApp();
    } catch (_) {}
  });

  testWidgets('VistaInventario - Tab navigation and editing', (WidgetTester tester) async {
    // Ignore layout overflow errors in test environment
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      final message = details.exception.toString();
      if (message.contains('overflowed') || message.contains('RenderFlex')) {
        return; // Ignore overflow errors
      }
      originalOnError?.call(details);
    };

    // Set desktop screen size
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: VistaInventario(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify "Datos Articulo" title is present
    expect(find.text("Datos Articulo"), findsOneWidget);

    // Helper to findFormField by its label
    Finder findFormField(String label) {
      final textFinder = find.text(label);
      final columnFinder = find.ancestor(of: textFinder, matching: find.byType(Column)).first;
      return find.descendant(of: columnFinder, matching: find.byType(TextFormField));
    }

    // Verify basic fields are visible in "Datos Artículos" tab (default)
    expect(findFormField("Nombre de Articulo"), findsOneWidget);
    expect(findFormField("Descripción del Articulo"), findsOneWidget);

    // Edit the product name field and check it changes the text
    final nameField = findFormField("Nombre de Articulo");
    await tester.enterText(nameField, "Updated Product Name");
    await tester.pumpAndSettle();

    // Verify it updated successfully
    expect(find.text("Updated Product Name"), findsOneWidget);

    // Now tap the "Datos Lote" tab to check accounting fields
    final datosLoteTab = find.text("Datos Lote");
    expect(datosLoteTab, findsOneWidget);
    await tester.tap(datosLoteTab);
    await tester.pumpAndSettle();

    // Verify accounting fields are now visible
    expect(findFormField("Costo Unitario"), findsOneWidget);
    expect(findFormField("Precio Venta"), findsOneWidget);
    expect(findFormField("Impuesto Compra %"), findsOneWidget);

    // Tap the "Contabilidad" tab to verify
    final contabilidadTab = find.text("Contabilidad");
    expect(contabilidadTab, findsOneWidget);
    await tester.tap(contabilidadTab);
    await tester.pumpAndSettle();

    // Verify "Añadir nuevo producto" button is visible under Contabilidad tab
    expect(find.text("Añadir nuevo producto"), findsOneWidget);

    // Reset physical size and restore onError
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    FlutterError.onError = originalOnError;
  });
}

class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return MockHttpClient();
  }
}

class MockHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #getUrl || 
        invocation.memberName == #openUrl || 
        invocation.memberName == #open) {
      return Future.value(MockHttpClientRequest());
    }
    return null;
  }
}

class MockHttpClientRequest implements HttpClientRequest {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #close) {
      return Future.value(MockHttpClientResponse());
    }
    if (invocation.memberName == #headers) {
      return MockHttpHeaders();
    }
    return null;
  }
}

class MockHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([transparentImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #statusCode) {
      return 200;
    }
    if (invocation.memberName == #contentLength) {
      return transparentImage.length;
    }
    if (invocation.memberName == #headers) {
      return MockHttpHeaders();
    }
    return null;
  }
}

class MockHttpHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

final Uint8List transparentImage = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82
]);
