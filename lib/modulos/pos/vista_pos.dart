import 'package:flutter/material.dart';
import 'package:confianza_admin/core/widgets/admin_layout.dart';

class VistaPos extends StatefulWidget {
  const VistaPos({super.key});

  @override
  State<VistaPos> createState() => _VistaPosState();
}

class _VistaPosState extends State<VistaPos> {
  @override
  Widget build(BuildContext context) {
    return const AdminLayout(
      activeRoute: '/pos',
      title: 'Instalador',
      child: SizedBox.expand(),
    );
  }
}
