import 'package:agri_store/logic/register/register_cubit.dart';
import 'package:agri_store/logic/register/register_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../componant/custom_text_field.dart';
import '../../data/model/user_model.dart';
import '../../data/my_database.dart';
import '../../dialog_utils.dart';
import '../../validation_utils.dart';
import '../home_screen.dart';
import '../login/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  static const String routeName = "Register";

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmationController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterCubit(),
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
                  child: BlocListener<RegisterCubit, RegisterState>(
                    listener: (context, state) {
                      if (state is RegisterFailure) {
                        DialogUtils.showMessage(
                          context,
                          state.errorMessage,
                          posActionName: 'OK',
                        );
                      } else if (state is RegisterSuccess) {
                        Navigator.pushReplacementNamed(
                          context,
                          HomeScreen.routeName,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Login successful")),
                        );
                      }
                    },
                    child: BlocBuilder<RegisterCubit, RegisterState>(
                      builder: (context, state) {
                        final isLoading = state is RegisterLoading;
                        return Form(
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                "Create Account",
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal[800],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              CustomTextFormField(
                                controller: nameController,
                                Label: "Full Name",
                                validator: (text) {
                                  if (text == null || text.trim().isEmpty) {
                                    return 'Please enter your full name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              CustomTextFormField(
                                controller: emailController,
                                Label: "Email",
                                validator: (text) {
                                  if (text == null || text.trim().isEmpty) {
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
                                  if (text == null || text.trim().isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (text.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              CustomTextFormField(
                                isPassword: true,
                                controller: passwordConfirmationController,
                                Label: "Confirm Password",
                                validator: (text) {
                                  if (text == null || text.trim().isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (text != passwordController.text) {
                                    return 'Passwords do not match';
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
                                onPressed:
                                    isLoading
                                        ? null
                                        : () {
                                          if (formKey.currentState!
                                              .validate()) {
                                            context
                                                .read<RegisterCubit>()
                                                .register(
                                                  nameController.text,
                                                  emailController.text,
                                                  passwordController.text,
                                                );
                                          }
                                        },
                                child:
                                    isLoading
                                        ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                        : const Text(
                                          'Register',
                                          style: TextStyle(fontSize: 18),
                                        ),
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    LoginScreen.routeName,
                                  );
                                },
                                child: const Text(
                                  "Already have an account? Login",
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
}
