import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_supabase_independent_music_streaming/admin/artist/ArtistManagementScreen.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddEditArtistScreen extends StatefulWidget {
  final String title;

  const AddEditArtistScreen({super.key, required this.title});

  @override
  _AddEditArtistScreenState createState() => _AddEditArtistScreenState();
}

class _AddEditArtistScreenState extends State<AddEditArtistScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final storage = FlutterSecureStorage();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureText = true;

  Map<String, dynamic>? _selectedRole = {'key': 'customer', 'value': 'Artist'};

  final List<Map<String, dynamic>> roles = [
    {'key': 'customer', 'value': 'Artist'},
    // {'key': 'delivery', 'value': 'Delivery'},
    {'key': 'admin', 'value': 'Admin'},
  ];

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final signUpResponse = await _supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        data: {
          'name': nameController.text.trim(),
          'phone': phoneController.text.trim(),
        },
      );

      if (signUpResponse.user != null) {
        Fluttertoast.showToast(msg: "Customer Added Successful!");
        // await _signIn();

        Navigator.pop(context);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ArtistManagementScreen(title: 'Artist Management',)),
        );

      } else {
        Fluttertoast.showToast(msg: "Registration failed.");
      }
    } catch (error) {
      Fluttertoast.showToast(msg: "Error: ${error.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: nameController,
                label: 'Full Name',
                validator: (value) => value!.isEmpty ? 'Enter a valid Full Name' : null,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: phoneController,
                label: 'Phone',
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Enter a valid Phone' : null,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty ? 'Enter a valid email' : null,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: passwordController,
                label: 'Password',
                obscureText: _obscureText,
                suffixIcon: IconButton(
                  icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                ),
                validator: (value) => value!.length < 6 ? 'Password must be at least 6 characters' : null,
              ),
              const SizedBox(height: 20),
              // DropdownButtonFormField<Map<String, dynamic>>(
              //   value: roles.firstWhere(
              //         (role) => role['key'] == _selectedRole?['key'],
              //     orElse: () => roles[0],
              //   ),
              //   decoration: const InputDecoration(labelText: 'Select Role'),
              //   items: roles.map((role) {
              //     return DropdownMenuItem<Map<String, dynamic>>(
              //       value: role,
              //       child: Text(role['value']),
              //     );
              //   }).toList(),
              //   onChanged: (value) => setState(() => _selectedRole = value),
              //   validator: (value) => value == null ? 'Please select a role' : null,
              // ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _signUp,
                child: const Text('Add Customer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }
}