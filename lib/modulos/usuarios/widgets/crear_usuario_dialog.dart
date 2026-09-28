import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel_usuarios.dart';

class CrearUsuarioDialog extends ConsumerStatefulWidget {
  const CrearUsuarioDialog({super.key});

  @override
  ConsumerState<CrearUsuarioDialog> createState() => _CrearUsuarioDialogState();
}

class _CrearUsuarioDialogState extends ConsumerState<CrearUsuarioDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  String? _selectedRole;
  String _selectedStatus = "Activo";
  bool _isLoading = false;

  static const Color colorPrimary = Color(0xFF006397);
  static const Color colorOutlineVariant = Color(0xFFBFC7D2);
  static const Color colorOnSurfaceVariant = Color(0xFF3F4850);

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _crearUsuario() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Debe seleccionar un rol")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final viewModel = ref.read(usuariosViewModelProvider.notifier);
      await viewModel.createUser(
        name: _nameController.text,
        lastName: _lastNameController.text,
        password: _passwordController.text,
        roleId: _selectedRole!,
        status: _selectedStatus,
      );
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Usuario creado exitosamente", style: TextStyle(color: Colors.white)), backgroundColor: Color(0xFF10B981)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final _ = ref.watch(usuariosViewModelProvider);
    final viewModel = ref.read(usuariosViewModelProvider.notifier);
    final roles = viewModel.profiles;

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.person_add, color: colorPrimary),
          SizedBox(width: 12),
          Text("Crear Nuevo Usuario", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _nameController,
                        decoration: _inputDecoration("Nombre(s)"),
                        validator: (v) => v!.isEmpty ? "Requerido" : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: _inputDecoration("Apellido(s)"),
                        validator: (v) => v!.isEmpty ? "Requerido" : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: _inputDecoration("Contraseña Temporal"),
                  obscureText: true,
                  validator: (v) => v!.length < 6 ? "Mínimo 6 caracteres" : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: _inputDecoration("Rol del Usuario"),
                  initialValue: _selectedRole,
                  items: roles.map((r) => DropdownMenuItem(value: r.id, child: Text(r.name))).toList(),
                  onChanged: (v) => setState(() => _selectedRole = v),
                  validator: (v) => v == null ? "Requerido" : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: _inputDecoration("Estado Inicial"),
                  initialValue: _selectedStatus,
                  items: ["Activo", "suspendido"].map((s) => DropdownMenuItem(value: s, child: Text(s == "suspendido" ? "Suspendido" : "Activo"))).toList(),
                  onChanged: (v) => setState(() => _selectedStatus = v!),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorPrimary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: _isLoading ? null : _crearUsuario,
          child: _isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text("Crear Usuario"),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: colorOnSurfaceVariant, fontSize: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: colorOutlineVariant)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
