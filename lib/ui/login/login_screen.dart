import 'package:agri_store/logic/login/login_cubit.dart';
import 'package:agri_store/logic/login/login_state.dart';
import 'package:agri_store/ui/home_screen.dart';
import 'package:agri_store/ui/register/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../componant/custom_text_field.dart';
import '../../data/my_database.dart';
import '../../dialog_utils.dart';
import '../../validation_utils.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = "login";

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFDFECDB), Color(0xFFE9F5E5)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 12,
                color: Colors.white.withOpacity(0.95),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: BlocListener<LoginCubit, LoginState>(
                    listener: (context, state) {
                      if (state is LoginFailure) {
                        DialogUtils.showMessage(
                          context,
                          state.errorMessage,
                          posActionName: 'OK',
                        );
                      } else if (state is LoginSuccess) {
                        Navigator.pushReplacementNamed(
                          context,
                          HomeScreen.routeName,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Login successful")),
                        );
                      }
                    },
                    child: BlocBuilder<LoginCubit, LoginState>(
                      builder: (context, state) {
                        final isLoading = state is LoginLoading;
                        return Form(
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                "Welcome Back!",
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal[800],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              CustomTextFormField(
                                controller: emailController,
                                Label: "Email",
                                validator: (text) {
                                  if (text == null || text
                                      .trim()
                                      .isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!ValidationUtils.isValidEmail(text)) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              CustomTextFormField(
                                isPassword: true,
                                controller: passwordController,
                                Label: "Password",
                                validator: (text) {
                                  if (text == null || text
                                      .trim()
                                      .isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (text.length < 6) {
                                    return "Password must be at least 6 characters";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: isLoading ? null : () {
                                  if (formKey.currentState!.validate()) {
                                    context.read<LoginCubit>().login(
                                        emailController.text,
                                        passwordController.text);
                                  }
                                },
                                child:
                                isLoading
                                    ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                    : const Text(
                                  'Login',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    RegisterScreen.routeName,
                                  );
                                },
                                child: const Text(
                                  "Don't have an account? Register here",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Future<void> login() async {
  //   if (!formKey.currentState!.validate()) return;
  //
  //   setState(() => isLoading = true);
  //
  //   try {
  //     final result = await FirebaseAuth.instance.signInWithEmailAndPassword(
  //       email: emailController.text.trim(),
  //       password: passwordController.text,
  //     );
  //
  //     final user = await MyDataBase.readUser(result.user?.uid ?? "");
  //
  //     if (!context.mounted) return;
  //
  //     if (user == null) {
  //       DialogUtils.showMessage(
  //         context,
  //         "User not found in database",
  //         posActionName: 'OK',
  //       );
  //       return;
  //     }
  //
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text("Login successful")));
  //
  //     Navigator.pushReplacementNamed(context, HomeScreen.routeName);
  //   } on FirebaseAuthException catch (_) {
  //     if (!context.mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Invalid email or password")),
  //     );
  //   } catch (e) {
  //     if (!context.mounted) return;
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text("Unexpected error: $e")));
  //   } finally {
  //     if (mounted) setState(() => isLoading = false);
  //   }
  // }
}
