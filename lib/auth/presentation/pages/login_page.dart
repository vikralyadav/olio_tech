import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/ auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthCubit>().login(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.isAuthenticated) {
          Navigator.pushReplacementNamed(context, "/home");
        }

        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<AuthCubit>();

        return Scaffold(
          appBar: AppBar(
            title: const Text("Login"),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [

                    const SizedBox(height: 30),

                    const FlutterLogo(
                      size: 120,
                    ),

                    const SizedBox(height: 30),

                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email is required";
                        }

                        final regex = RegExp(
                            r'^[^@]+@[^@]+\.[^@]+');

                        if (!regex.hasMatch(value)) {
                          return "Invalid Email";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: passwordController,
                      obscureText: state.obscurePassword,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: const OutlineInputBorder(),
                        prefixIcon:
                        const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            state.obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            cubit.togglePasswordVisibility();
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.length < 6) {
                          return "Minimum 6 characters";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Checkbox(
                          value: state.rememberMe,
                          onChanged: (value) {
                            cubit.toggleRememberMe(
                                value ?? false);
                          },
                        ),
                        const Text("Remember Me"),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            cubit.forgotPassword(
                                emailController.text);
                          },
                          child: const Text(
                              "Forgot Password?"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: state.isLoading
                            ? null
                            : _login,
                        child: state.isLoading
                            ? const CircularProgressIndicator()
                            : const Text("Login"),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [

                        const Text(
                          "Don't have an account?",
                        ),

                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                const RegisterPage(),
                              ),
                            );
                          },
                          child: const Text("Register"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}